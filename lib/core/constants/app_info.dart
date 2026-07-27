/// Static product identity strings used across trust screens and branding.
/// Keep these in sync with the store listing and privacy policy before release.
abstract final class AppInfo {
  static const String appName = 'ML Leaf';
  static const String fullTitle = 'ML Leaf - Learn Machine Learning';
  static const String tagline =
      'Grow Your Machine Learning Skills, One Concept at a Time';
  static const String brandIdea =
      'Learning grows step by step, like leaves on a healthy plant.';

  /// Semantic version shown on the About screen. Mirror pubspec `version`.
  static const String versionName = '1.0.0';

  /// Placeholder — replace before any Play release and never change afterwards.
  static const String packageId = 'com.example.mlleaf';

  static const String supportEmail = 'support@example.com';
  static const String copyright = '© 2026 ML Leaf';
}
