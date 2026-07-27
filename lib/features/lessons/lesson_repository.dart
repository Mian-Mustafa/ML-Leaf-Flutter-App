import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/errors/content_exception.dart';
import 'lesson.dart';

typedef AssetLoader = Future<String> Function(String path);

/// Loads and validates lessons for a module from its bundled JSON file
/// (`assets/content/lessons/<moduleId>.json`). Modules without a lesson file
/// yet simply return an empty list, so the UI shows a "coming soon" state
/// rather than an error.
class LessonRepository {
  LessonRepository({AssetLoader? loader})
      : _loader = loader ?? rootBundle.loadString;

  final AssetLoader _loader;
  final Map<String, List<Lesson>> _cache = {};

  String _pathFor(String moduleId) => 'assets/content/lessons/$moduleId.json';

  Future<List<Lesson>> loadForModule(String moduleId) async {
    if (_cache.containsKey(moduleId)) return _cache[moduleId]!;

    final String raw;
    try {
      raw = await _loader(_pathFor(moduleId));
    } catch (_) {
      // No lesson file bundled for this module yet.
      return _cache[moduleId] = const [];
    }

    final Map<String, dynamic> decoded;
    try {
      decoded = json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw ContentException('Lessons file is not valid JSON',
          source: _pathFor(moduleId));
    }

    final list = decoded['lessons'];
    if (list is! List) {
      throw ContentException('Lessons file is missing a "lessons" list',
          source: _pathFor(moduleId));
    }

    final lessons = <Lesson>[];
    final seenIds = <String>{};
    for (final entry in list) {
      if (entry is! Map<String, dynamic>) {
        throw ContentException('Each lesson must be an object',
            source: _pathFor(moduleId));
      }
      final lesson = Lesson.fromJson(entry);
      if (lesson.moduleId != moduleId) {
        throw ContentException(
          'Lesson "${lesson.id}" has moduleId "${lesson.moduleId}" '
          'but is in $moduleId.json',
          source: _pathFor(moduleId),
        );
      }
      if (!seenIds.add(lesson.id)) {
        throw ContentException('Duplicate lesson id "${lesson.id}"',
            source: _pathFor(moduleId));
      }
      lessons.add(lesson);
    }

    lessons.sort((a, b) => a.order.compareTo(b.order));
    return _cache[moduleId] = List.unmodifiable(lessons);
  }
}
