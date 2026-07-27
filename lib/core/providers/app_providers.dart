import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/preferences_service.dart';

/// Provides the initialised [PreferencesService]. Overridden in [main] with the
/// concrete instance created during startup, so it is available synchronously
/// throughout the widget tree.
final preferencesServiceProvider = Provider<PreferencesService>(
  (ref) => throw UnimplementedError(
    'preferencesServiceProvider must be overridden in main()',
  ),
);

/// Whether the user has completed (or skipped) onboarding. Mutable so the
/// splash/onboarding flow can advance navigation once finished.
final onboardingCompleteProvider =
    NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).onboardingComplete;

  Future<void> complete() async {
    await ref.read(preferencesServiceProvider).setOnboardingComplete(true);
    state = true;
  }

  /// Used by the reset flow (FR-14) to return to a clean state.
  Future<void> reset() async {
    await ref.read(preferencesServiceProvider).setOnboardingComplete(false);
    state = false;
  }
}

/// Current theme mode (light / dark / system), persisted to preferences.
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(preferencesServiceProvider).themeMode;

  Future<void> set(ThemeMode mode) async {
    await ref.read(preferencesServiceProvider).setThemeMode(mode);
    state = mode;
  }
}
