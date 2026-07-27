import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlleaf/features/lessons/content_block.dart';
import 'package:mlleaf/features/lessons/lesson_repository.dart';

/// Content testing (§21) for Module 2 (Data Preprocessing): validates the
/// bundled lesson JSON parses, is well-formed, and that every referenced figure
/// asset is loadable.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('data_preprocessing lessons load, ordered, unique ids', () async {
    final repo = LessonRepository(loader: rootBundle.loadString);
    final lessons = await repo.loadForModule('data_preprocessing');

    expect(lessons.length, 14);
    expect(lessons.map((l) => l.id).toSet().length, lessons.length);

    final orders = lessons.map((l) => l.order).toList();
    expect(orders, [...orders]..sort());

    for (final l in lessons) {
      expect(l.moduleId, 'data_preprocessing');
      expect(l.title.trim(), isNotEmpty);
      expect(l.keyPoints, isNotEmpty);
    }
  });

  test('every figure referenced in Module 2 exists as an asset', () async {
    final repo = LessonRepository(loader: rootBundle.loadString);
    final lessons = await repo.loadForModule('data_preprocessing');

    final assets = <String>{
      for (final l in lessons)
        for (final b in l.content)
          if (b is ImageBlock) b.asset,
    };
    expect(assets.length, greaterThanOrEqualTo(20));
    for (final asset in assets) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(0), reason: asset);
    }
  });
}
