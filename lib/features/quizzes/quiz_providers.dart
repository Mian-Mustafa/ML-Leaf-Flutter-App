import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'quiz_models.dart';
import 'quiz_repository.dart';

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => QuizRepository(),
);

final quizBankProvider = FutureProvider.family<QuizBank?, String>((
  ref,
  moduleId,
) {
  return ref.watch(quizRepositoryProvider).loadForModule(moduleId);
});
