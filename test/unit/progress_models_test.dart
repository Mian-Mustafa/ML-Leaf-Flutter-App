import 'package:flutter_test/flutter_test.dart';
import 'package:mlleaf/core/models/quiz_attempt_record.dart';
import 'package:mlleaf/features/lessons/content_block.dart';
import 'package:mlleaf/features/lessons/lesson.dart';
import 'package:mlleaf/features/modules/module.dart';
import 'package:mlleaf/features/progress/progress_models.dart';

void main() {
  const module = Module(
    id: 'foundations',
    order: 1,
    title: 'Foundations',
    summary: 'Core concepts',
    iconKey: 'foundations',
  );
  const lessonOne = Lesson(
    id: 'lesson-1',
    moduleId: 'foundations',
    order: 1,
    title: 'First lesson',
    summary: 'A lesson',
    difficulty: Difficulty.beginner,
    readingMinutes: 5,
    contentVersion: 1,
    content: [ParagraphBlock(text: 'Content')],
    keyPoints: [],
    keywords: [],
  );
  const lessonTwo = Lesson(
    id: 'lesson-2',
    moduleId: 'foundations',
    order: 2,
    title: 'Second lesson',
    summary: 'Another lesson',
    difficulty: Difficulty.beginner,
    readingMinutes: 5,
    contentVersion: 1,
    content: [ParagraphBlock(text: 'Content')],
    keyPoints: [],
    keywords: [],
  );

  test('uses the latest quiz attempt for dashboard performance', () {
    final newer = QuizAttemptRecord(
      moduleId: 'foundations',
      difficultyId: 'easy',
      correct: 24,
      total: 30,
      completedAt: DateTime(2026, 8, 14),
    );
    final older = QuizAttemptRecord(
      moduleId: 'foundations',
      difficultyId: 'easy',
      correct: 12,
      total: 30,
      completedAt: DateTime(2026, 8, 13),
    );
    final dashboard = StudyDashboard.fromContent(
      modules: const [module],
      lessonGroups: const [
        [lessonOne, lessonTwo],
      ],
      progress: StudyProgressState(
        completedLessonIds: const {'lesson-1'},
        quizAttempts: [newer, older],
      ),
    );

    expect(dashboard.lessonCompletion, 0.5);
    expect(dashboard.attemptedQuizLevels, 1);
    expect(dashboard.correctQuizAnswers, 24);
    expect(dashboard.answeredQuizQuestions, 30);
    expect(dashboard.quizAccuracy, 0.8);
  });
}
