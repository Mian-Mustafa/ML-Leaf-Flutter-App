# MLleaf — Learn Machine Learning

An **offline-first** Flutter (Android) app for learning machine learning:
structured lessons, Python examples, quizzes, flashcards, interview questions,
search, bookmarks and local progress tracking. No accounts, no network, no ads.

> Grow Your Machine Learning Skills, One Concept at a Time

This repository implements the **MLleaf Enhanced Documentation Plan (v1.0)**.

## Tech stack

| Concern          | Choice                                  |
|------------------|-----------------------------------------|
| Framework        | Flutter / Dart                          |
| State management | Riverpod                                |
| Navigation       | GoRouter (stateful shell + branches)    |
| Content          | Versioned JSON assets (offline)         |
| Local study data | Hive                                    |
| Small settings   | SharedPreferences (theme, onboarding)   |
| Release format   | Android App Bundle (.aab)               |

## Project layout

```
lib/
├── main.dart              # startup: Hive + preferences, then runApp
├── app/                   # app root, theme (design system), router, nav shell
├── core/
│   ├── constants/         # colours, product info, storage keys
│   ├── providers/         # Riverpod providers (prefs, theme, onboarding)
│   ├── services/          # PreferencesService
│   └── widgets/           # shared widgets
└── features/              # feature-first: onboarding, home, modules, lessons,
                           # quizzes, flashcards, interview, search, bookmarks,
                           # progress, settings, splash
assets/content/            # lessons / quizzes / flashcards / interview_questions
```

## Build status

- **Phase 1 (complete):** project scaffold, design system (light/dark),
  navigation shell, splash + onboarding, working theme switching, trust screens
  (About / Privacy), and placeholders for every specified feature. Runnable
  shell — `flutter analyze` clean, smoke test passing, debug APK builds.
- **UI/UX upgrade (complete):** design-token layer (spacing / radius / motion /
  sizes), semantic-colour `ThemeExtension`, reusable components (`AppCard`,
  `StatusBadge`, `AppProgressBar`, `EmptyStateView`, `SectionHeader`,
  `BookmarkButton`), branded gradients, page transitions and micro-animations,
  a WCAG 2.1 AA contrast pass (all pairs ≥4.5:1) and screen-reader semantics.
- **Next:** Phase 2 — content models (Lesson/Quiz/Flashcard/Progress), JSON
  schema + repositories, Hive persistence, content validation.

### Design tokens & components

- `core/constants/app_spacing.dart` — `AppSpacing`, `AppRadius`, `AppSizes`
- `core/constants/app_motion.dart` — `AppMotion` (durations + curves)
- `app/semantic_colors.dart` — success / warning / info via `context.semantic`
- `app/brand_gradient.dart` — leaf-inspired header/hero gradients
- `core/widgets/` — the reusable component set (states per design system §13.5)

## Running

```bash
flutter pub get
flutter run            # on an Android emulator or device
```

Useful checks:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Notes

- **Package ID** is the placeholder `com.example.mlleaf` — must be set to a real
  reverse-domain ID before any Play release, and never changed afterwards.
- **Offline-first:** startup and all core learning flows never touch the
  network. (Fonts are intentionally the bundled system typography for this
  reason — no runtime font fetching.)
- If pub cache (`C:`) and this project (`E:`) are on different drives, Kotlin's
  incremental compile cache is disabled for Android builds. Harmless, but
  rebuilds are slower.
