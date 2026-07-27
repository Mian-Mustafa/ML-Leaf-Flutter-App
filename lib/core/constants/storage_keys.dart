/// Keys for SharedPreferences and Hive boxes. Centralised so storage contracts
/// are visible in one place and safe to evolve with migrations.
abstract final class StorageKeys {
  // SharedPreferences
  static const String onboardingComplete = 'onboarding_complete';
  static const String themeMode = 'theme_mode'; // 'light' | 'dark' | 'system'

  // Hive boxes (used from Phase 2 onwards)
  static const String progressBox = 'progress_box';
  static const String quizHistoryBox = 'quiz_history_box';
  static const String bookmarksBox = 'bookmarks_box';
  static const String flashcardStatusBox = 'flashcard_status_box';
}
