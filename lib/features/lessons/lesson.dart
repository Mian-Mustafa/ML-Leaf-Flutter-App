import '../../core/errors/content_exception.dart';
import 'content_block.dart';

enum Difficulty {
  beginner,
  intermediate,
  advanced;

  static Difficulty fromKey(String? key) {
    switch (key) {
      case 'intermediate':
        return Difficulty.intermediate;
      case 'advanced':
        return Difficulty.advanced;
      case 'beginner':
        return Difficulty.beginner;
      default:
        throw ContentException('Unknown difficulty "$key"');
    }
  }

  String get label => switch (this) {
        Difficulty.beginner => 'Beginner',
        Difficulty.intermediate => 'Intermediate',
        Difficulty.advanced => 'Advanced',
      };
}

/// A single lesson (documentation plan §17.1). `id` is a stable content
/// contract (§18): renaming it after release disconnects saved progress.
class Lesson {
  const Lesson({
    required this.id,
    required this.moduleId,
    required this.order,
    required this.title,
    required this.summary,
    required this.difficulty,
    required this.readingMinutes,
    required this.contentVersion,
    required this.content,
    required this.keyPoints,
    required this.keywords,
    this.commonMistakes = const [],
    this.relatedQuizId,
  });

  final String id;
  final String moduleId;
  final int order;
  final String title;
  final String summary;
  final Difficulty difficulty;
  final int readingMinutes;
  final int contentVersion;
  final List<ContentBlock> content;
  final List<String> keyPoints;
  final List<String> keywords;
  final List<String> commonMistakes;
  final String? relatedQuizId;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    String requireString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw ContentException('Lesson field "$key" is missing or empty',
            source: json['id']?.toString());
      }
      return value;
    }

    List<String> stringList(String key) {
      final value = json[key];
      if (value == null) return const [];
      if (value is! List) {
        throw ContentException('Lesson field "$key" must be a list',
            source: json['id']?.toString());
      }
      return value.map((e) => e.toString()).toList();
    }

    final contentJson = json['content'];
    if (contentJson is! List || contentJson.isEmpty) {
      throw ContentException('Lesson "content" must be a non-empty list',
          source: json['id']?.toString());
    }

    return Lesson(
      id: requireString('id'),
      moduleId: requireString('moduleId'),
      order: (json['order'] as num?)?.toInt() ?? 0,
      title: requireString('title'),
      summary: requireString('summary'),
      difficulty: Difficulty.fromKey(json['difficulty'] as String?),
      readingMinutes: (json['readingMinutes'] as num?)?.toInt() ?? 1,
      contentVersion: (json['contentVersion'] as num?)?.toInt() ?? 1,
      content: contentJson
          .map((b) => ContentBlock.fromJson(b as Map<String, dynamic>))
          .toList(),
      keyPoints: stringList('keyPoints'),
      keywords: stringList('keywords'),
      commonMistakes: stringList('commonMistakes'),
      relatedQuizId: json['relatedQuizId'] as String?,
    );
  }
}
