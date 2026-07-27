import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'module.dart';
import 'module_repository.dart';

/// Repository access point for module content.
final moduleRepositoryProvider =
    Provider<ModuleRepository>((ref) => ModuleRepository());

/// All learning modules, ordered. Surfaces loading/error/data states to the UI.
final modulesProvider = FutureProvider<List<Module>>((ref) {
  return ref.watch(moduleRepositoryProvider).loadModules();
});

/// A single module by id, or null if it does not exist. Used by the lesson list
/// and Home's continue-learning surfaces.
final moduleByIdProvider = Provider.family<Module?, String>((ref, id) {
  final modules = ref.watch(modulesProvider).valueOrNull;
  if (modules == null) return null;
  for (final module in modules) {
    if (module.id == id) return module;
  }
  return null;
});
