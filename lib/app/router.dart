import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/bookmarks/bookmarks_screen.dart';
import '../features/flashcards/flashcard_module_screen.dart';
import '../features/flashcards/flashcards_screen.dart';
import '../features/home/home_screen.dart';
import '../features/interview/interview_screen.dart';
import '../features/interview/interview_practice_screen.dart';
import '../features/lessons/lesson_detail_screen.dart';
import '../features/lessons/lesson_list_screen.dart';
import '../features/modules/modules_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/quizzes/quiz_level_screen.dart';
import '../features/quizzes/quiz_assessment_screen.dart';
import '../features/quizzes/quizzes_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/about_screen.dart';
import '../features/settings/privacy_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import 'scaffold_with_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// App-wide navigation configuration (plan section: GoRouter, structured
/// routes). A stateful shell hosts the five primary destinations; full-screen
/// flows (lesson reader, quizzes, trust screens) are pushed above the shell.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ScaffoldWithNavBar(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/modules',
              builder: (context, state) => const ModulesScreen(),
              routes: [
                GoRoute(
                  path: ':moduleId',
                  builder: (context, state) => LessonListScreen(
                    moduleId: state.pathParameters['moduleId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/progress',
              builder: (context, state) => const ProgressScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/lessons/:moduleId/:lessonId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => LessonDetailScreen(
        moduleId: state.pathParameters['moduleId']!,
        lessonId: state.pathParameters['lessonId']!,
      ),
    ),
    GoRoute(
      path: '/quizzes',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const QuizzesScreen(),
      routes: [
        GoRoute(
          path: ':moduleId',
          builder: (context, state) =>
              QuizLevelScreen(moduleId: state.pathParameters['moduleId']!),
          routes: [
            GoRoute(
              path: ':difficultyId',
              builder: (context, state) => QuizAssessmentScreen(
                moduleId: state.pathParameters['moduleId']!,
                startingLevelId: state.pathParameters['difficultyId']!,
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/flashcards',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FlashcardsScreen(),
      routes: [
        GoRoute(
          path: ':moduleId',
          builder: (context, state) => FlashcardModuleScreen(
            moduleId: state.pathParameters['moduleId']!,
          ),
          routes: [
            GoRoute(
              path: ':viewId',
              builder: (context, state) => FlashcardVisualScreen(
                moduleId: state.pathParameters['moduleId']!,
                viewId: state.pathParameters['viewId']!,
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/interview',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const InterviewScreen(),
      routes: [
        GoRoute(
          path: ':trackId',
          builder: (context, state) => InterviewPracticeScreen(
            trackId: state.pathParameters['trackId']!,
            initialQuestionIndex:
                (int.tryParse(state.uri.queryParameters['question'] ?? '1') ??
                    1) -
                1,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/bookmarks',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BookmarksScreen(),
    ),
    GoRoute(
      path: '/about',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/privacy',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PrivacyScreen(),
    ),
  ],
);
