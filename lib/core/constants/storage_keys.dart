/// Keys for SharedPreferences and Hive boxes. Centralised so storage contracts
/// are visible in one place and safe to evolve with migrations.
abstract final class StorageKeys {
  // SharedPreferences
  static const String onboardingComplete = 'onboarding_complete';
  static const String themeMode = 'theme_mode'; // 'light' | 'dark' | 'system'
  static const String bookmarkedLessonIds = 'bookmarked_lesson_ids';
  static const String completedLessonIds = 'completed_lesson_ids';
  static const String completedInterviewTrackIds =
      'completed_interview_track_ids';
  static const String quizAttempts = 'quiz_attempts';

  // Hive boxes (used from Phase 2 onwards)
  static const String progressBox = 'progress_box';
  static const String quizHistoryBox = 'quiz_history_box';
  static const String bookmarksBox = 'bookmarks_box';
  static const String flashcardStatusBox = 'flashcard_status_box';
}
