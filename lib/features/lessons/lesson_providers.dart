import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lesson.dart';
import 'lesson_repository.dart';

final lessonRepositoryProvider =
    Provider<LessonRepository>((ref) => LessonRepository());

/// Lessons for a module, ordered. Empty if the module has no content yet.
final lessonsByModuleProvider =
    FutureProvider.family<List<Lesson>, String>((ref, moduleId) {
  return ref.watch(lessonRepositoryProvider).loadForModule(moduleId);
});

/// Number of lessons in a module (for module cards). Null while loading.
final lessonCountProvider = Provider.family<int?, String>((ref, moduleId) {
  return ref.watch(lessonsByModuleProvider(moduleId)).valueOrNull?.length;
});

/// A single lesson identified by its module and lesson id.
final lessonProvider =
    FutureProvider.family<Lesson?, ({String moduleId, String lessonId})>(
        (ref, key) async {
  final lessons =
      await ref.watch(lessonsByModuleProvider(key.moduleId).future);
  for (final lesson in lessons) {
    if (lesson.id == key.lessonId) return lesson;
  }
  return null;
});
