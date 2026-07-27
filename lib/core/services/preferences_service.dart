import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

/// Thin wrapper over [SharedPreferences] for small app settings such as theme
/// mode and onboarding completion (documentation plan section 15.3).
///
/// Larger study data (progress, quiz history, bookmarks, flashcard status)
/// lives in Hive and is added in Phase 2.
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static Future<PreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  bool get onboardingComplete =>
      _prefs.getBool(StorageKeys.onboardingComplete) ?? false;

  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(StorageKeys.onboardingComplete, value);

  ThemeMode get themeMode {
    switch (_prefs.getString(StorageKeys.themeMode)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(StorageKeys.themeMode, mode.name);

  /// Clears every preference. Used by the Settings reset flow (FR-14).
  Future<void> clear() => _prefs.clear();
}
