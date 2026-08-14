import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../lessons/lesson.dart';
import '../lessons/lesson_providers.dart';
import '../modules/module_providers.dart';
import '../quizzes/quiz_models.dart';
import '../quizzes/quiz_providers.dart';
import 'study_search_index.dart';

final studySearchIndexProvider = FutureProvider<StudySearchIndex>((ref) async {
  final modules = await ref.watch(modulesProvider.future);
  final repository = ref.watch(lessonRepositoryProvider);
  final lessonGroups = await Future.wait<List<Lesson>>(
    modules.map((module) => repository.loadForModule(module.id)),
  );
  final quizRepository = ref.watch(quizRepositoryProvider);
  final loadedQuizBanks = await Future.wait<QuizBank?>(
    modules.map((module) => quizRepository.loadForModule(module.id)),
  );
  final quizBanks = <String, QuizBank>{
    for (var index = 0; index < modules.length; index++)
      modules[index].id: ?loadedQuizBanks[index],
  };

  return StudySearchIndex(
    modules: modules,
    lessons: lessonGroups.expand((group) => group).toList(growable: false),
    quizBanks: quizBanks,
  );
});
