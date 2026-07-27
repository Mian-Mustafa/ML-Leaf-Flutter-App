// Smoke test for the MLleaf app shell: the splash screen shows branding and
// routes a first-time user to onboarding, fully offline.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlleaf/app/app.dart';
import 'package:mlleaf/core/providers/app_providers.dart';
import 'package:mlleaf/core/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('First launch shows splash then onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PreferencesService.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [preferencesServiceProvider.overrideWithValue(prefs)],
        child: const MLleafApp(),
      ),
    );

    // Splash branding.
    await tester.pump();
    expect(find.text('ML Leaf'), findsOneWidget);

    // Splash routes onward to onboarding for a new user.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Get started'), findsNothing); // starts on first page
  });

  testWidgets('Skipping onboarding lands on the upgraded Home', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PreferencesService.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [preferencesServiceProvider.overrideWithValue(prefs)],
        child: const MLleafApp(),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Home surfaces the study tools and the "start learning" prompt.
    expect(find.text('Study tools'), findsOneWidget);
    expect(find.text('Start learning'), findsOneWidget);
    expect(find.text('Just started'), findsOneWidget); // status badge
  });
}
