import '../interview/interview_data.dart';
import '../lessons/content_block.dart';
import '../lessons/lesson.dart';
import '../modules/module.dart';
import '../quizzes/quiz_models.dart';
import 'search_models.dart';

/// A small in-memory index over bundled learning content. The app is
/// offline-first, so ranking is deterministic and all matching stays on-device.
class StudySearchIndex {
  StudySearchIndex({
    required this.modules,
    required this.lessons,
    this.quizBanks = const {},
  });

  final List<Module> modules;
  final List<Lesson> lessons;
  final Map<String, QuizBank> quizBanks;

  List<StudySearchResult> search(
    String rawQuery, {
    SearchFilter filter = SearchFilter.all,
  }) {
    final query = _normalise(rawQuery);
    if (query.isEmpty) return const [];

    final terms = query.split(' ');
    final ranked =
        <_RankedResult>[
            ..._moduleResults(terms),
            ..._lessonResults(terms),
            ..._quizResults(terms),
            ..._interviewResults(terms),
          ].where((item) => _matchesFilter(item.result.type, filter)).toList()
          ..sort((a, b) {
            final scoreOrder = b.score.compareTo(a.score);
            if (scoreOrder != 0) return scoreOrder;
            return a.result.title.compareTo(b.result.title);
          });

    return ranked.map((item) => item.result).toList(growable: false);
  }

  Iterable<_RankedResult> _moduleResults(List<String> terms) sync* {
    for (final module in modules) {
      final title = _normalise(module.title);
      final body = _normalise('${module.title} ${module.summary}');
      final score = _score(title: title, body: body, terms: terms);
      if (score == 0) continue;
      yield _RankedResult(
        score: score,
        result: StudySearchResult(
          type: SearchResultType.module,
          title: module.title,
          subtitle: 'Module ${module.order.toString().padLeft(2, '0')}',
          excerpt: module.summary,
          moduleId: module.id,
        ),
      );
    }
  }

  Iterable<_RankedResult> _lessonResults(List<String> terms) sync* {
    for (final lesson in lessons) {
      final title = _normalise(lesson.title);
      final searchable = _lessonText(lesson);
      final score = _score(title: title, body: searchable, terms: terms);
      if (score == 0) continue;

      yield _RankedResult(
        score: score,
        result: StudySearchResult(
          type: SearchResultType.lesson,
          title: lesson.title,
          subtitle: _moduleTitle(lesson.moduleId),
          excerpt: _excerpt(searchable, terms, phrase: terms.join(' ')),
          moduleId: lesson.moduleId,
          lessonId: lesson.id,
        ),
      );
    }
  }

  Iterable<_RankedResult> _interviewResults(List<String> terms) sync* {
    for (final track in InterviewData.tracks) {
      for (
        var questionIndex = 0;
        questionIndex < track.questions.length;
        questionIndex++
      ) {
        final question = track.questions[questionIndex];
        final title = _normalise(question.prompt);
        final body = _normalise(
          '${track.title} ${track.subtitle} ${question.prompt} '
          '${question.focusPoints.join(' ')} ${question.followUp}',
        );
        final score = _score(title: title, body: body, terms: terms);
        if (score == 0) continue;

        yield _RankedResult(
          score: score,
          result: StudySearchResult(
            type: SearchResultType.interview,
            title: question.prompt,
            subtitle: track.title,
            excerpt: 'Focus: ${question.focusPoints.join(' | ')}',
            moduleId: question.moduleIds.first,
            trackId: track.id,
            questionIndex: questionIndex,
          ),
        );
      }
    }
  }

  Iterable<_RankedResult> _quizResults(List<String> terms) sync* {
    for (final entry in quizBanks.entries) {
      final moduleId = entry.key;
      final bank = entry.value;
      for (final difficulty in QuizDifficulty.values) {
        for (final question in bank.questionsFor(difficulty)) {
          final title = _normalise(question.prompt);
          final body = _normalise(
            '${bank.title} ${difficulty.label} ${question.prompt} '
            '${question.options.join(' ')}',
          );
          final score = _score(title: title, body: body, terms: terms);
          if (score == 0) continue;

          yield _RankedResult(
            score: score,
            result: StudySearchResult(
              type: SearchResultType.quiz,
              title: question.prompt,
              subtitle: '${bank.title} | ${difficulty.label} quiz',
              excerpt: 'Question ${question.number.toString().padLeft(3, '0')}',
              moduleId: moduleId,
              difficultyId: difficulty.id,
            ),
          );
        }
      }
    }
  }

  String _moduleTitle(String id) {
    for (final module in modules) {
      if (module.id == id) return module.title;
    }
    return 'Learning module';
  }
}

class _RankedResult {
  const _RankedResult({required this.score, required this.result});

  final int score;
  final StudySearchResult result;
}

bool _matchesFilter(SearchResultType type, SearchFilter filter) {
  return switch (filter) {
    SearchFilter.all => true,
    SearchFilter.modules => type == SearchResultType.module,
    SearchFilter.lessons => type == SearchResultType.lesson,
    SearchFilter.quizzes => type == SearchResultType.quiz,
    SearchFilter.interview => type == SearchResultType.interview,
  };
}

int _score({
  required String title,
  required String body,
  required List<String> terms,
}) {
  var score = 0;
  for (final term in terms) {
    if (!body.contains(term)) return 0;
    score += 2;
    if (title.contains(term)) score += 8;
  }
  return score;
}

String _lessonText(Lesson lesson) {
  final fragments = <String>[
    lesson.title,
    lesson.summary,
    ...lesson.keywords,
    ...lesson.keyPoints,
    ...lesson.commonMistakes,
    ...lesson.content.expand(_blockText),
  ];
  return _normalise(fragments.join(' '));
}

Iterable<String> _blockText(ContentBlock block) {
  return switch (block) {
    HeadingBlock() => [block.text],
    ParagraphBlock() => [block.text],
    BulletsBlock() => block.items,
    NumberedBlock() => block.items,
    ImageBlock() => [if (block.caption != null) block.caption!],
    FormulaBlock() => [
      block.expression,
      if (block.explanation != null) block.explanation!,
    ],
    CodeBlock() => [
      block.code,
      if (block.explanation != null) block.explanation!,
    ],
    TableBlock() => [...block.headers, ...block.rows.expand((row) => row)],
    CalloutBlock() => [if (block.title != null) block.title!, block.text],
    DefinitionBlock() => [
      block.term,
      if (block.source != null) block.source!,
      block.text,
    ],
  };
}

String _excerpt(String text, List<String> terms, {String? phrase}) {
  var matchIndex = -1;
  var matchLength = 0;

  final exactPhrase = phrase?.trim();
  if (exactPhrase != null && exactPhrase.isNotEmpty) {
    matchIndex = text.indexOf(exactPhrase);
    if (matchIndex >= 0) matchLength = exactPhrase.length;
  }

  if (matchIndex < 0) {
    for (final term in terms) {
      final index = text.indexOf(term);
      if (index >= 0 && (matchIndex < 0 || index < matchIndex)) {
        matchIndex = index;
        matchLength = term.length;
      }
    }
  }

  if (matchIndex < 0) {
    return text.length <= 170 ? text : '${text.substring(0, 167)}...';
  }

  const radius = 86;
  final start = (matchIndex - radius).clamp(0, text.length);
  final end = (matchIndex + matchLength + radius).clamp(0, text.length);
  final prefix = start > 0 ? '...' : '';
  final suffix = end < text.length ? '...' : '';
  return '$prefix${text.substring(start, end).trim()}$suffix';
}

String _normalise(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}
