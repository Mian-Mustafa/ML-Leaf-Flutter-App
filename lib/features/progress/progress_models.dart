import '../../core/models/quiz_attempt_record.dart';
import '../lessons/lesson.dart';
import '../modules/module.dart';
import '../quizzes/quiz_models.dart';

/// Mutable study data that belongs to the learner rather than content assets.
class StudyProgressState {
  const StudyProgressState({
    required this.completedLessonIds,
    required this.quizAttempts,
  });

  factory StudyProgressState.empty() => const StudyProgressState(
    completedLessonIds: <String>{},
    quizAttempts: <QuizAttemptRecord>[],
  );

  final Set<String> completedLessonIds;
  final List<QuizAttemptRecord> quizAttempts;

  Map<String, QuizAttemptRecord> get latestQuizAttempts {
    final latest = <String, QuizAttemptRecord>{};
    for (final attempt in quizAttempts) {
      latest.putIfAbsent(attempt.levelKey, () => attempt);
    }
    return Map.unmodifiable(latest);
  }
}

class ModuleStudyProgress {
  const ModuleStudyProgress({
    required this.module,
    required this.totalLessons,
    required this.completedLessons,
    required this.quizAttempts,
  });

  final Module module;
  final int totalLessons;
  final int completedLessons;
  final List<QuizAttemptRecord> quizAttempts;

  int get attemptedLevels => quizAttempts.length;
  int get totalLevels => QuizDifficulty.values.length;
  double get lessonCompletion =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;
  bool get isStarted => completedLessons > 0 || quizAttempts.isNotEmpty;
}

/// Fully-resolved dashboard metrics. It keeps rendering code focused on the
/// presentation rather than repeatedly aggregating raw learning records.
class StudyDashboard {
  const StudyDashboard({
    required this.modules,
    required this.totalLessons,
    required this.completedLessons,
    required this.latestQuizAttempts,
    required this.recentQuizAttempts,
  });

  final List<ModuleStudyProgress> modules;
  final int totalLessons;
  final int completedLessons;
  final List<QuizAttemptRecord> latestQuizAttempts;
  final List<QuizAttemptRecord> recentQuizAttempts;

  int get totalQuizLevels => modules.length * QuizDifficulty.values.length;
  int get attemptedQuizLevels => latestQuizAttempts.length;
  int get correctQuizAnswers =>
      latestQuizAttempts.fold(0, (sum, attempt) => sum + attempt.correct);
  int get answeredQuizQuestions =>
      latestQuizAttempts.fold(0, (sum, attempt) => sum + attempt.total);
  int get incorrectQuizAnswers => answeredQuizQuestions - correctQuizAnswers;
  int get startedModules => modules.where((module) => module.isStarted).length;
  int get completedModules =>
      modules.where((module) => module.lessonCompletion >= 1).length;

  double get lessonCompletion =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;
  double get quizCoverage =>
      totalQuizLevels == 0 ? 0 : attemptedQuizLevels / totalQuizLevels;
  double get quizAccuracy => answeredQuizQuestions == 0
      ? 0
      : correctQuizAnswers / answeredQuizQuestions;

  factory StudyDashboard.fromContent({
    required List<Module> modules,
    required List<List<Lesson>> lessonGroups,
    required StudyProgressState progress,
  }) {
    final latestAttempts = progress.latestQuizAttempts;
    final moduleProgress = <ModuleStudyProgress>[];
    var totalLessons = 0;
    var completedLessons = 0;

    for (var index = 0; index < modules.length; index++) {
      final lessons = lessonGroups[index];
      final completed = lessons
          .where((lesson) => progress.completedLessonIds.contains(lesson.id))
          .length;
      final moduleAttempts = QuizDifficulty.values
          .map(
            (difficulty) =>
                latestAttempts['${modules[index].id}:${difficulty.id}'],
          )
          .whereType<QuizAttemptRecord>()
          .toList();

      totalLessons += lessons.length;
      completedLessons += completed;
      moduleProgress.add(
        ModuleStudyProgress(
          module: modules[index],
          totalLessons: lessons.length,
          completedLessons: completed,
          quizAttempts: List.unmodifiable(moduleAttempts),
        ),
      );
    }

    return StudyDashboard(
      modules: List.unmodifiable(moduleProgress),
      totalLessons: totalLessons,
      completedLessons: completedLessons,
      latestQuizAttempts: List.unmodifiable(latestAttempts.values.toList()),
      recentQuizAttempts: List.unmodifiable(
        progress.quizAttempts.take(4).toList(),
      ),
    );
  }
}
