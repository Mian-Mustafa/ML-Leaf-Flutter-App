import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlleaf/features/lessons/content_block.dart';
import 'package:mlleaf/features/lessons/lesson_repository.dart';

/// Content testing (§21) for Module 8 (Feature Engineering): validates the
/// bundled lesson JSON parses, is well-formed, and that every referenced figure
/// asset is loadable.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('feature_engineering lessons load, ordered, unique ids', () async {
    final repo = LessonRepository(loader: rootBundle.loadString);
    final lessons = await repo.loadForModule('feature_engineering');

    expect(lessons.length, 25);
    expect(lessons.map((l) => l.id).toSet().length, lessons.length);

    final orders = lessons.map((l) => l.order).toList();
    expect(orders, [...orders]..sort());

    for (final l in lessons) {
      expect(l.moduleId, 'feature_engineering');
      expect(l.title.trim(), isNotEmpty);
    }
  });

  test('every figure referenced in Module 8 exists as an asset', () async {
    final repo = LessonRepository(loader: rootBundle.loadString);
    final lessons = await repo.loadForModule('feature_engineering');

    final assets = <String>{
      for (final l in lessons)
        for (final b in l.content)
          if (b is ImageBlock) b.asset,
    };
    for (final asset in assets) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(0), reason: asset);
    }
  });
}
