import 'package:flutter_test/flutter_test.dart';
import 'package:mlleaf/features/lessons/content_block.dart';
import 'package:mlleaf/features/lessons/lesson.dart';
import 'package:mlleaf/features/modules/module.dart';
import 'package:mlleaf/features/quizzes/quiz_models.dart';
import 'package:mlleaf/features/search/search_models.dart';
import 'package:mlleaf/features/search/study_search_index.dart';

void main() {
  final modules = [
    const Module(
      id: 'evaluation',
      order: 1,
      title: 'Model Evaluation',
      summary: 'Reliable validation and leakage prevention.',
      iconKey: 'evaluation',
    ),
  ];
  final lessons = [
    const Lesson(
      id: 'leakage',
      moduleId: 'evaluation',
      order: 1,
      title: 'Preventing data leakage',
      summary: 'Keep future information out of training.',
      difficulty: Difficulty.intermediate,
      readingMinutes: 6,
      contentVersion: 1,
      keywords: ['leakage', 'cross-validation'],
      keyPoints: ['Fit preprocessing on training data only.'],
      content: [
        CalloutBlock(
          variant: CalloutVariant.warning,
          title: 'Leakage warning',
          text: 'Data leakage produces overly optimistic validation scores.',
        ),
      ],
    ),
  ];
  final quizBanks = <String, QuizBank>{
    'evaluation': QuizBank(
      moduleId: 'evaluation',
      title: 'Model Evaluation',
      questionsByDifficulty: {
        QuizDifficulty.easy: const [
          QuizQuestion(
            id: 'quiz-1',
            number: 1,
            prompt: 'What is cross-validation used for?',
            options: ['Drawing charts', 'Model evaluation'],
            correctOption: 1,
          ),
        ],
      },
    ),
  };
  final index = StudySearchIndex(
    modules: modules,
    lessons: lessons,
    quizBanks: quizBanks,
  );

  test('searches lesson content and returns a contextual lesson result', () {
    final results = index.search('optimistic validation');

    expect(results, hasLength(1));
    expect(results.single.type, SearchResultType.lesson);
    expect(results.single.lessonId, 'leakage');
    expect(results.single.excerpt, contains('optimistic validation'));
  });

  test('filters results by content type', () {
    final results = index.search('evaluation', filter: SearchFilter.modules);

    expect(results, hasLength(1));
    expect(results.single.type, SearchResultType.module);
  });

  test('indexes interview prompts with a deep-link question position', () {
    final results = index.search('out-of-fold predictions');
    final interview = results.firstWhere(
      (result) => result.type == SearchResultType.interview,
    );

    expect(interview.trackId, 'ensembles');
    expect(interview.questionIndex, isNotNull);
  });

  test('indexes quiz questions with the relevant level', () {
    final results = index.search('cross-validation used');
    final quiz = results.firstWhere(
      (result) => result.type == SearchResultType.quiz,
    );

    expect(quiz.moduleId, 'evaluation');
    expect(quiz.difficultyId, 'easy');
  });
}
