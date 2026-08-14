import 'package:flutter_test/flutter_test.dart';
import 'package:mlleaf/core/models/quiz_attempt_record.dart';
import 'package:mlleaf/core/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists unique, non-empty bookmarked lesson ids', () async {
    final service = PreferencesService(await SharedPreferences.getInstance());

    await service.setBookmarkedLessonIds([
      'lesson-2',
      '',
      'lesson-1',
      'lesson-2',
    ]);

    expect(service.bookmarkedLessonIds, {'lesson-1', 'lesson-2'});
  });

  test('persists lesson completion and recent quiz attempts', () async {
    final service = PreferencesService(await SharedPreferences.getInstance());
    final attempt = QuizAttemptRecord(
      moduleId: 'foundations',
      difficultyId: 'easy',
      correct: 23,
      total: 30,
      completedAt: DateTime.utc(2026, 8, 14),
    );

    await service.setCompletedLessonIds(['lesson-2', 'lesson-1', 'lesson-1']);
    await service.setQuizAttempts([attempt]);

    expect(service.completedLessonIds, {'lesson-1', 'lesson-2'});
    expect(service.quizAttempts, hasLength(1));
    expect(service.quizAttempts.single.correct, 23);
    expect(service.quizAttempts.single.difficultyId, 'easy');
  });
}
