import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';
import '../models/quiz_attempt_record.dart';

/// Thin wrapper over [SharedPreferences] for small app settings such as theme
/// mode and onboarding completion (documentation plan section 15.3).
///
/// Lightweight learner state, including progress and recent assessment results,
/// stays in preferences. Larger offline study records can move to Hive without
/// changing the UI-facing service contract.
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

  Set<String> get bookmarkedLessonIds {
    final savedIds =
        _prefs.getStringList(StorageKeys.bookmarkedLessonIds) ??
        const <String>[];
    return savedIds.where((id) => id.trim().isNotEmpty).toSet();
  }

  Future<void> setBookmarkedLessonIds(Iterable<String> ids) {
    final savedIds = ids.where((id) => id.trim().isNotEmpty).toSet().toList()
      ..sort();
    return _prefs.setStringList(StorageKeys.bookmarkedLessonIds, savedIds);
  }

  Set<String> get completedLessonIds {
    final completedIds =
        _prefs.getStringList(StorageKeys.completedLessonIds) ??
        const <String>[];
    return completedIds.where((id) => id.trim().isNotEmpty).toSet();
  }

  Future<void> setCompletedLessonIds(Iterable<String> ids) {
    final completedIds =
        ids.where((id) => id.trim().isNotEmpty).toSet().toList()..sort();
    return _prefs.setStringList(StorageKeys.completedLessonIds, completedIds);
  }

  Set<String> get completedInterviewTrackIds {
    final completedIds =
        _prefs.getStringList(StorageKeys.completedInterviewTrackIds) ??
        const <String>[];
    return completedIds.where((id) => id.trim().isNotEmpty).toSet();
  }

  Future<void> setCompletedInterviewTrackIds(Iterable<String> ids) {
    final completedIds =
        ids.where((id) => id.trim().isNotEmpty).toSet().toList()..sort();
    return _prefs.setStringList(
      StorageKeys.completedInterviewTrackIds,
      completedIds,
    );
  }

  List<QuizAttemptRecord> get quizAttempts {
    final encoded = _prefs.getString(StorageKeys.quizAttempts);
    if (encoded == null || encoded.isEmpty) return const <QuizAttemptRecord>[];

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return const <QuizAttemptRecord>[];

      final attempts =
          decoded
              .map(QuizAttemptRecord.tryParse)
              .whereType<QuizAttemptRecord>()
              .toList()
            ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return List.unmodifiable(attempts);
    } on FormatException {
      return const <QuizAttemptRecord>[];
    }
  }

  Future<void> setQuizAttempts(Iterable<QuizAttemptRecord> attempts) {
    final trimmed = attempts.toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    // Enough history for meaningful recent activity, while keeping this small
    // SharedPreferences payload bounded on low-storage devices.
    final recent = trimmed
        .take(120)
        .map((attempt) => attempt.toJson())
        .toList();
    return _prefs.setString(StorageKeys.quizAttempts, jsonEncode(recent));
  }

  /// Clears every preference. Used by the Settings reset flow (FR-14).
  Future<void> clear() => _prefs.clear();
}
