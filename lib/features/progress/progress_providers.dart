import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/quiz_attempt_record.dart';
import '../../core/providers/app_providers.dart';
import '../lessons/lesson.dart';
import '../lessons/lesson_providers.dart';
import '../modules/module_providers.dart';
import '../quizzes/quiz_models.dart';
import 'progress_models.dart';

/// The single source of truth for completed lessons and submitted quiz levels.
final studyProgressProvider =
    NotifierProvider<StudyProgressNotifier, StudyProgressState>(
      StudyProgressNotifier.new,
    );

class StudyProgressNotifier extends Notifier<StudyProgressState> {
  @override
  StudyProgressState build() {
    final preferences = ref.watch(preferencesServiceProvider);
    return StudyProgressState(
      completedLessonIds: Set.unmodifiable(preferences.completedLessonIds),
      completedInterviewTrackIds: Set.unmodifiable(
        preferences.completedInterviewTrackIds,
      ),
      quizAttempts: preferences.quizAttempts,
    );
  }

  Future<void> toggleLessonCompletion(String lessonId) async {
    final completed = Set<String>.from(state.completedLessonIds);
    if (!completed.add(lessonId)) completed.remove(lessonId);

    state = StudyProgressState(
      completedLessonIds: Set.unmodifiable(completed),
      completedInterviewTrackIds: state.completedInterviewTrackIds,
      quizAttempts: state.quizAttempts,
    );
    await ref.read(preferencesServiceProvider).setCompletedLessonIds(completed);
  }

  Future<void> recordQuizAttempt({
    required String moduleId,
    required LevelQuizResult result,
  }) async {
    final attempt = QuizAttemptRecord(
      moduleId: moduleId,
      difficultyId: result.difficulty.id,
      correct: result.score.correct,
      total: result.score.total,
      completedAt: DateTime.now(),
    );
    final attempts =
        ([attempt, ...state.quizAttempts]
              ..sort((a, b) => b.completedAt.compareTo(a.completedAt)))
            .take(120)
            .toList();

    state = StudyProgressState(
      completedLessonIds: state.completedLessonIds,
      completedInterviewTrackIds: state.completedInterviewTrackIds,
      quizAttempts: List.unmodifiable(attempts),
    );
    await ref.read(preferencesServiceProvider).setQuizAttempts(attempts);
  }

  Future<void> markInterviewTrackComplete(String trackId) async {
    final normalizedTrackId = trackId.trim();
    if (normalizedTrackId.isEmpty ||
        state.completedInterviewTrackIds.contains(normalizedTrackId)) {
      return;
    }

    final completed = {...state.completedInterviewTrackIds, normalizedTrackId};
    state = StudyProgressState(
      completedLessonIds: state.completedLessonIds,
      completedInterviewTrackIds: Set.unmodifiable(completed),
      quizAttempts: state.quizAttempts,
    );
    await ref
        .read(preferencesServiceProvider)
        .setCompletedInterviewTrackIds(completed);
  }
}

/// Content-aware dashboard data. It reacts to study actions by depending on
/// [studyProgressProvider] and preserves module order from the content source.
final studyDashboardProvider = FutureProvider<StudyDashboard>((ref) async {
  final progress = ref.watch(studyProgressProvider);
  final modules = await ref.watch(modulesProvider.future);
  final lessonGroups = await Future.wait<List<Lesson>>(
    modules.map(
      (module) => ref.watch(lessonsByModuleProvider(module.id).future),
    ),
  );

  return StudyDashboard.fromContent(
    modules: modules,
    lessonGroups: lessonGroups,
    progress: progress,
  );
});
