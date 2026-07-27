import 'package:flutter_test/flutter_test.dart';
import 'package:mlleaf/core/errors/content_exception.dart';
import 'package:mlleaf/features/modules/module_repository.dart';

void main() {
  ModuleRepository repoFor(String json) =>
      ModuleRepository(loader: (_) async => json);

  test('parses and orders modules by order field', () async {
    final repo = repoFor('''
      {"modules":[
        {"id":"b","order":2,"title":"B","summary":"s","icon":"neural"},
        {"id":"a","order":1,"title":"A","summary":"s","icon":"data"}
      ]}
    ''');
    final modules = await repo.loadModules();
    expect(modules.map((m) => m.id).toList(), ['a', 'b']);
    expect(modules.first.title, 'A');
  });

  test('rejects duplicate ids (§17.5)', () async {
    final repo = repoFor('''
      {"modules":[
        {"id":"x","order":1,"title":"X","summary":"s","icon":"data"},
        {"id":"x","order":2,"title":"X2","summary":"s","icon":"data"}
      ]}
    ''');
    expect(repo.loadModules(), throwsA(isA<ContentException>()));
  });

  test('rejects empty required fields', () async {
    final repo = repoFor(
        '{"modules":[{"id":"","order":1,"title":"X","summary":"s","icon":"data"}]}');
    expect(repo.loadModules(), throwsA(isA<ContentException>()));
  });

  test('rejects a non-integer order', () async {
    final repo = repoFor(
        '{"modules":[{"id":"a","order":"1","title":"X","summary":"s","icon":"data"}]}');
    expect(repo.loadModules(), throwsA(isA<ContentException>()));
  });

  test('rejects malformed JSON', () async {
    final repo = repoFor('not json');
    expect(repo.loadModules(), throwsA(isA<ContentException>()));
  });

  test('rejects a missing modules list', () async {
    final repo = repoFor('{"contentVersion":1}');
    expect(repo.loadModules(), throwsA(isA<ContentException>()));
  });
}
