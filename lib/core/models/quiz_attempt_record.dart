/// A completed quiz-level submission kept locally for progress reporting.
///
/// The record deliberately stores only outcome metadata, never answer choices.
/// That keeps the study dashboard useful without persisting assessment answers.
class QuizAttemptRecord {
  const QuizAttemptRecord({
    required this.moduleId,
    required this.difficultyId,
    required this.correct,
    required this.total,
    required this.completedAt,
  });

  final String moduleId;
  final String difficultyId;
  final int correct;
  final int total;
  final DateTime completedAt;

  double get accuracy => total == 0 ? 0 : correct / total;

  String get levelKey => '$moduleId:$difficultyId';

  Map<String, Object> toJson() => {
    'moduleId': moduleId,
    'difficultyId': difficultyId,
    'correct': correct,
    'total': total,
    'completedAt': completedAt.toUtc().toIso8601String(),
  };

  static QuizAttemptRecord? tryParse(Object? value) {
    if (value is! Map) return null;

    final moduleId = value['moduleId'];
    final difficultyId = value['difficultyId'];
    final correct = value['correct'];
    final total = value['total'];
    final completedAt = value['completedAt'];
    if (moduleId is! String ||
        moduleId.trim().isEmpty ||
        difficultyId is! String ||
        difficultyId.trim().isEmpty ||
        correct is! num ||
        total is! num ||
        completedAt is! String) {
      return null;
    }

    final completed = DateTime.tryParse(completedAt);
    final correctValue = correct.toInt();
    final totalValue = total.toInt();
    if (completed == null ||
        totalValue <= 0 ||
        correctValue < 0 ||
        correctValue > totalValue) {
      return null;
    }

    return QuizAttemptRecord(
      moduleId: moduleId,
      difficultyId: difficultyId,
      correct: correctValue,
      total: totalValue,
      completedAt: completed.toLocal(),
    );
  }
}
