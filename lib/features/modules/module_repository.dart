import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/errors/content_exception.dart';
import 'module.dart';

/// Loads and validates learning modules from the bundled JSON asset. The UI
/// never reads the asset directly — it goes through this repository
/// (architecture §15: controlled interface between logic and stored data).
/// Loads the raw contents of an asset. Injectable so the repository can be
/// unit tested without the asset bundle.
typedef AssetLoader = Future<String> Function(String path);

class ModuleRepository {
  ModuleRepository({
    this.assetPath = 'assets/content/modules.json',
    AssetLoader? loader,
  }) : _loader = loader ?? rootBundle.loadString;

  final String assetPath;
  final AssetLoader _loader;

  List<Module>? _cache;

  /// Returns all modules, ordered by their `order` field. Result is cached
  /// after the first successful load (content is static within a run).
  Future<List<Module>> loadModules() async {
    if (_cache != null) return _cache!;

    final String raw;
    try {
      raw = await _loader(assetPath);
    } catch (_) {
      throw ContentException('Could not load modules', source: assetPath);
    }

    final Map<String, dynamic> decoded;
    try {
      decoded = json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw ContentException('Modules file is not valid JSON',
          source: assetPath);
    }

    final list = decoded['modules'];
    if (list is! List) {
      throw ContentException('Modules file is missing a "modules" list',
          source: assetPath);
    }

    final modules = <Module>[];
    final seenIds = <String>{};
    for (final entry in list) {
      if (entry is! Map<String, dynamic>) {
        throw ContentException('Each module must be an object',
            source: assetPath);
      }
      final module = Module.fromJson(entry);
      if (!seenIds.add(module.id)) {
        // §17.5: every ID must be unique.
        throw ContentException('Duplicate module id "${module.id}"',
            source: assetPath);
      }
      modules.add(module);
    }

    modules.sort((a, b) => a.order.compareTo(b.order));
    return _cache = List.unmodifiable(modules);
  }
}
