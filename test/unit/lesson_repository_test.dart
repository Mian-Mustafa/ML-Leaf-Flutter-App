import 'package:flutter_test/flutter_test.dart';
import 'package:mlleaf/core/errors/content_exception.dart';
import 'package:mlleaf/features/lessons/content_block.dart';
import 'package:mlleaf/features/lessons/lesson.dart';
import 'package:mlleaf/features/lessons/lesson_repository.dart';

void main() {
  const validLesson = '''
    {"lessons":[{
      "id":"m_01","moduleId":"m","order":1,"title":"T","summary":"s",
      "difficulty":"beginner","readingMinutes":3,"contentVersion":1,
      "keywords":["a"],"keyPoints":["k"],
      "content":[
        {"type":"paragraph","text":"hello"},
        {"type":"image","asset":"assets/x.png","caption":"cap"},
        {"type":"table","headers":["A","B"],"rows":[["1","2"]]},
        {"type":"callout","variant":"warning","text":"careful"}
      ]
    }]}
  ''';

  LessonRepository repoFor(String json) =>
      LessonRepository(loader: (_) async => json);

  test('parses a lesson and its content blocks', () async {
    final lessons = await repoFor(validLesson).loadForModule('m');
    expect(lessons, hasLength(1));
    final l = lessons.single;
    expect(l.difficulty, Difficulty.beginner);
    expect(l.content.whereType<ImageBlock>(), hasLength(1));
    expect(l.content.whereType<TableBlock>().single.rows.first, ['1', '2']);
    expect(l.content.whereType<CalloutBlock>().single.variant,
        CalloutVariant.warning);
  });

  test('returns empty list when a module has no lesson file', () async {
    final repo = LessonRepository(loader: (_) async => throw 'not found');
    expect(await repo.loadForModule('missing'), isEmpty);
  });

  test('rejects a lesson whose moduleId does not match the file', () async {
    final json = validLesson.replaceFirst('"moduleId":"m"', '"moduleId":"other"');
    expect(repoFor(json).loadForModule('m'),
        throwsA(isA<ContentException>()));
  });

  test('rejects an unknown block type', () async {
    final json = validLesson.replaceFirst(
        '{"type":"paragraph","text":"hello"}', '{"type":"mystery"}');
    expect(repoFor(json).loadForModule('m'),
        throwsA(isA<ContentException>()));
  });

  test('rejects an empty content list', () async {
    const json = '''
      {"lessons":[{"id":"m_01","moduleId":"m","order":1,"title":"T",
      "summary":"s","difficulty":"beginner","readingMinutes":1,
      "contentVersion":1,"content":[]}]}''';
    expect(repoFor(json).loadForModule('m'),
        throwsA(isA<ContentException>()));
  });
}
