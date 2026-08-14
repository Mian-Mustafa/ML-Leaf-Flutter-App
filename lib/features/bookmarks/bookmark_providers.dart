import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../lessons/lesson.dart';
import '../lessons/lesson_providers.dart';
import '../modules/module.dart';
import '../modules/module_providers.dart';

/// Persistent lesson ids saved by the learner. The value is kept synchronous
/// after app startup, so bookmark controls react immediately across screens.
final bookmarkedLessonIdsProvider =
    NotifierProvider<BookmarkedLessonIdsNotifier, Set<String>>(
      BookmarkedLessonIdsNotifier.new,
    );

class BookmarkedLessonIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return Set.unmodifiable(
      ref.watch(preferencesServiceProvider).bookmarkedLessonIds,
    );
  }

  Future<void> toggle(String lessonId) async {
    final next = Set<String>.from(state);
    if (!next.add(lessonId)) next.remove(lessonId);

    state = Set.unmodifiable(next);
    await ref.read(preferencesServiceProvider).setBookmarkedLessonIds(state);
  }

  Future<void> remove(String lessonId) async {
    if (!state.contains(lessonId)) return;

    final next = Set<String>.from(state)..remove(lessonId);
    state = Set.unmodifiable(next);
    await ref.read(preferencesServiceProvider).setBookmarkedLessonIds(state);
  }

  Future<void> clear() async {
    state = const <String>{};
    await ref.read(preferencesServiceProvider).setBookmarkedLessonIds(state);
  }
}

/// A saved lesson paired with its parent module for contextual navigation.
class BookmarkedLesson {
  const BookmarkedLesson({required this.lesson, required this.module});

  final Lesson lesson;
  final Module module;
}

/// Resolves saved ids into content records. Missing ids are ignored so a
/// content update cannot break the bookmarks screen for existing learners.
final bookmarkedLessonsProvider = FutureProvider<List<BookmarkedLesson>>((
  ref,
) async {
  final savedIds = ref.watch(bookmarkedLessonIdsProvider);
  if (savedIds.isEmpty) return const <BookmarkedLesson>[];

  final modules = await ref.watch(modulesProvider.future);
  final savedLessons = <BookmarkedLesson>[];

  for (final module in modules) {
    final lessons = await ref.watch(lessonsByModuleProvider(module.id).future);
    for (final lesson in lessons) {
      if (savedIds.contains(lesson.id)) {
        savedLessons.add(BookmarkedLesson(lesson: lesson, module: module));
      }
    }
  }

  return savedLessons;
});
