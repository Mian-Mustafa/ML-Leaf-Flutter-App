import '../../core/errors/content_exception.dart';

enum QuizDifficulty {
  easy('easy', 'Easy'),
  medium('medium', 'Medium'),
  hard('hard', 'Hard');

  const QuizDifficulty(this.id, this.label);

  final String id;
  final String label;

  static QuizDifficulty? fromId(String id) {
    for (final difficulty in values) {
      if (difficulty.id == id) return difficulty;
    }
    return null;
  }
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.number,
    required this.prompt,
    required this.options,
    required this.correctOption,
    this.figureAsset,
  });

  final String id;
  final int number;
  final String prompt;
  final List<String> options;

  /// Exactly one correct choice, represented by its zero-based option index.
  final int correctOption;

  /// Optional source figure needed to interpret a visual assessment question.
  final String? figureAsset;

  factory QuizQuestion.fromJson(Map<String, dynamic> json, String source) {
    String requiredText(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw ContentException(
          'Quiz question field "$key" is missing or empty',
          source: source,
        );
      }
      return value;
    }

    final number = json['number'];
    final correctOption = json['correctOption'];
    final rawOptions = json['options'];
    final figureAsset = json['figureAsset'];
    if (number is! int || number <= 0) {
      throw ContentException(
        'Quiz question number must be a positive integer',
        source: source,
      );
    }
    if (rawOptions is! List || rawOptions.length < 2) {
      throw ContentException(
        'Quiz question must include at least two answer options',
        source: source,
      );
    }
    final options = <String>[];
    for (final option in rawOptions) {
      if (option is! String || option.trim().isEmpty) {
        throw ContentException(
          'Quiz answer options must be non-empty strings',
          source: source,
        );
      }
      options.add(option);
    }
    if (correctOption is! int ||
        correctOption < 0 ||
        correctOption >= options.length) {
      throw ContentException(
        'Quiz question has an invalid correct option index',
        source: source,
      );
    }
    if (figureAsset != null &&
        (figureAsset is! String || figureAsset.trim().isEmpty)) {
      throw ContentException(
        'Quiz figure asset must be a non-empty string when provided',
        source: source,
      );
    }

    return QuizQuestion(
      id: requiredText('id'),
      number: number,
      prompt: requiredText('prompt'),
      options: List.unmodifiable(options),
      correctOption: correctOption,
      figureAsset: figureAsset as String?,
    );
  }
}

class QuizBank {
  const QuizBank({
    required this.moduleId,
    required this.title,
    required this.questionsByDifficulty,
  });

  final String moduleId;
  final String title;
  final Map<QuizDifficulty, List<QuizQuestion>> questionsByDifficulty;

  List<QuizQuestion> questionsFor(QuizDifficulty difficulty) =>
      questionsByDifficulty[difficulty] ?? const [];

  List<QuizQuestion> get allQuestions => [
    for (final difficulty in QuizDifficulty.values) ...questionsFor(difficulty),
  ];

  factory QuizBank.fromJson(Map<String, dynamic> json, String source) {
    String requiredText(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw ContentException(
          'Quiz bank field "$key" is missing or empty',
          source: source,
        );
      }
      return value;
    }

    final rawLevels = json['levels'];
    if (rawLevels is! Map<String, dynamic>) {
      throw ContentException('Quiz bank is missing "levels"', source: source);
    }

    final questionsByDifficulty = <QuizDifficulty, List<QuizQuestion>>{};
    final ids = <String>{};
    final numbers = <int>{};
    final prompts = <String>{};
    for (final difficulty in QuizDifficulty.values) {
      final rawQuestions = rawLevels[difficulty.id];
      if (rawQuestions is! List || rawQuestions.isEmpty) {
        throw ContentException(
          'Quiz level "${difficulty.id}" must include questions',
          source: source,
        );
      }
      final questions = <QuizQuestion>[];
      for (final rawQuestion in rawQuestions) {
        if (rawQuestion is! Map<String, dynamic>) {
          throw ContentException(
            'Each quiz question must be an object',
            source: source,
          );
        }
        final question = QuizQuestion.fromJson(rawQuestion, source);
        if (!ids.add(question.id) ||
            !numbers.add(question.number) ||
            !prompts.add(question.prompt.trim().toLowerCase())) {
          throw ContentException(
            'Quiz questions must not be duplicated',
            source: source,
          );
        }
        questions.add(question);
      }
      questions.sort((a, b) => a.number.compareTo(b.number));
      questionsByDifficulty[difficulty] = List.unmodifiable(questions);
    }

    return QuizBank(
      moduleId: requiredText('moduleId'),
      title: requiredText('title'),
      questionsByDifficulty: Map.unmodifiable(questionsByDifficulty),
    );
  }
}

class QuizScore {
  const QuizScore({required this.correct, required this.total});

  final int correct;
  final int total;

  int get incorrect => total - correct;
}

/// The scored result for one independently attempted difficulty level.
class LevelQuizResult {
  const LevelQuizResult({
    required this.difficulty,
    required this.score,
    required this.answers,
  });

  final QuizDifficulty difficulty;
  final QuizScore score;
  final Map<String, int> answers;

  bool isCorrect(QuizQuestion question) =>
      answers[question.id] == question.correctOption;

  factory LevelQuizResult.evaluate({
    required QuizDifficulty difficulty,
    required List<QuizQuestion> questions,
    required Map<String, int> answers,
  }) {
    final correct = questions
        .where((question) => answers[question.id] == question.correctOption)
        .length;

    return LevelQuizResult(
      difficulty: difficulty,
      score: QuizScore(correct: correct, total: questions.length),
      answers: Map.unmodifiable(Map.of(answers)),
    );
  }
}

class QuizResult {
  const QuizResult({required this.scores, required this.answers});

  final Map<QuizDifficulty, QuizScore> scores;
  final Map<String, int> answers;

  QuizScore scoreFor(QuizDifficulty difficulty) => scores[difficulty]!;

  QuizScore get overall => QuizScore(
    correct: scores.values.fold(0, (sum, score) => sum + score.correct),
    total: scores.values.fold(0, (sum, score) => sum + score.total),
  );

  bool isCorrect(QuizQuestion question) =>
      answers[question.id] == question.correctOption;

  factory QuizResult.evaluate(QuizBank bank, Map<String, int> answers) {
    final scores = <QuizDifficulty, QuizScore>{};
    for (final difficulty in QuizDifficulty.values) {
      final questions = bank.questionsFor(difficulty);
      final correct = questions
          .where((question) => answers[question.id] == question.correctOption)
          .length;
      scores[difficulty] = QuizScore(correct: correct, total: questions.length);
    }
    return QuizResult(
      scores: Map.unmodifiable(scores),
      answers: Map.unmodifiable(Map.of(answers)),
    );
  }
}
