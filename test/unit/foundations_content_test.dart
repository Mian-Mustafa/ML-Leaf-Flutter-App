import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlleaf/features/lessons/content_block.dart';
import 'package:mlleaf/features/lessons/lesson_repository.dart';

/// Content testing (§21): validates the actual bundled foundations.json so a
/// typo in the lesson content fails CI. Also checks that every figure asset
/// referenced by an ImageBlock is declared and loadable.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('foundations lessons load, are ordered, and have unique ids', () async {
    final repo = LessonRepository(loader: rootBundle.loadString);
    final lessons = await repo.loadForModule('foundations');

    expect(lessons.length, 10);
    expect(lessons.map((l) => l.id).toSet().length, lessons.length);

    final orders = lessons.map((l) => l.order).toList();
    expect(orders, [...orders]..sort());

    for (final l in lessons) {
      expect(l.title.trim(), isNotEmpty);
      expect(l.keyPoints, isNotEmpty);
    }
  });

  test('every figure referenced by a lesson exists as an asset', () async {
    final repo = LessonRepository(loader: rootBundle.loadString);
    final lessons = await repo.loadForModule('foundations');

    final assets = <String>{
      for (final l in lessons)
        for (final b in l.content)
          if (b is ImageBlock) b.asset,
    };
    expect(assets, isNotEmpty);

    for (final asset in assets) {
      // Throws if the asset is not bundled.
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(0), reason: asset);
    }
  });
}
