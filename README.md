# ML Leaf

ML Leaf is an offline-first Flutter app for learning machine learning through
structured lessons, quizzes, flashcards, interview practice, and local progress
tracking.

> Grow Your Machine Learning Skills, One Concept at a Time.

## Features

- Nine machine-learning modules, from foundations and data preprocessing to
  model evaluation, feature engineering, and ensemble methods.
- Offline lesson content with key points, code examples, and supporting visual
  assets.
- Per-module quizzes with easy, medium, and hard difficulty levels.
- Flashcards and visual review modes for core concepts.
- Five interview-practice tracks plus a mock interview round.
- Search across lessons, quiz questions, and interview prompts.
- Bookmarks for lessons and local learning-history controls.
- A combined Home progress indicator that equally reflects lesson completion,
  quiz-level completion, and completed interview tracks.
- Light, dark, and system themes, plus in-app About, privacy, and data-reset
  screens.

## Tech Stack

| Area | Technology |
| --- | --- |
| Framework | Flutter and Dart |
| State management | Riverpod |
| Navigation | GoRouter with a stateful navigation shell |
| Course content | Bundled JSON and image assets |
| Local state | SharedPreferences; Hive is initialized for local storage support |
| Code rendering | flutter_highlight |
| Android application ID | `com.mlleaf.app` |

## Project Structure

```text
lib/
  app/                 App setup, routing, theme, and navigation shell
  core/                Shared models, services, providers, constants, widgets
  features/            Feature-first screens and state
    bookmarks/         Saved lesson bookmarks
    flashcards/        Module flashcards and visual review
    home/              Home dashboard and combined progress snapshot
    interview/         Practice tracks and mock interview
    lessons/           Lesson models, repositories, lists, and reader
    modules/           Course module catalogue
    progress/          Learner progress and dashboard metrics
    quizzes/           Quiz banks, levels, and assessment flow
    search/            Unified study-content search
    settings/          Theme, privacy, reset, and About screens
assets/content/        Bundled module, lesson, and quiz JSON
assets/images/         Course and quiz visual assets
docs/                  Google Play privacy and Data Safety checklist
test/                  Unit and widget tests
```

## Requirements

- Flutter SDK with Dart `^3.11.1`
- Android device/emulator, Windows, Chrome, or Edge for local runs

## Run Locally

```bash
flutter pub get
flutter devices
flutter run -d <device-id>
```

For example, use `flutter run` after selecting an Android device or emulator.
The app is designed to work offline after installation because course content is
bundled with the app.

## Validate the Project

```bash
flutter analyze
flutter test
flutter build apk --debug
```

The automated suite covers bundled course content, quiz structure, interview
content, local preference persistence, progress calculations, search indexing,
and core widget rendering.

## Android Builds

Create an Android App Bundle for Google Play:

```bash
flutter build appbundle
```

Output:

```text
build/app/outputs/bundle/release/app-release.aab
```

Create an APK for direct device installation and testing:

```bash
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Use the `.aab` file for Google Play Console. Use the `.apk` file for direct
installation on an Android device. Before any Play upload, replace the current
debug signing configuration with a private upload key. Keep the keystore and
its passwords outside this repository. The application ID `com.mlleaf.app`
must not change after the first Play release.

## Privacy and Google Play

ML Leaf has no account, advertising, analytics, crash-reporting, or network
client dependency in its release build. Learner progress, bookmarks, quiz
history, interview completion, and settings stay on the device.

Read [the Google Play Data Safety checklist](docs/google_play_data_safety.md)
before publishing. It includes the current Data Safety declaration, privacy
policy hosting requirements, and release checks. The in-app privacy policy must
also be published at a stable public HTTPS URL before Play submission.

## Support

Contact: [mustafa39078@gmail.com](mailto:mustafa39078@gmail.com)
