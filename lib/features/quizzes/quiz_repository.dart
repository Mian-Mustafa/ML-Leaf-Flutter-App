import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/errors/content_exception.dart';
import '../modules/module_repository.dart' show AssetLoader;
import 'quiz_models.dart';

/// Loads a locally bundled quiz bank for a main module. A missing file means
/// that module's questions have not been added yet, rather than an app error.
class QuizRepository {
  QuizRepository({AssetLoader? loader})
    : _loader = loader ?? rootBundle.loadString;

  final AssetLoader _loader;
  final Map<String, QuizBank?> _cache = {};

  String _pathFor(String moduleId) => 'assets/content/quizzes/$moduleId.json';

  Future<QuizBank?> loadForModule(String moduleId) async {
    if (_cache.containsKey(moduleId)) return _cache[moduleId];

    final path = _pathFor(moduleId);
    final String raw;
    try {
      raw = await _loader(path);
    } catch (_) {
      return _cache[moduleId] = null;
    }

    final Map<String, dynamic> decoded;
    try {
      decoded = json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw ContentException('Quiz bank is not valid JSON', source: path);
    }

    final bank = QuizBank.fromJson(decoded, path);
    if (bank.moduleId != moduleId) {
      throw ContentException(
        'Quiz bank moduleId does not match its asset path',
        source: path,
      );
    }
    return _cache[moduleId] = bank;
  }
}
