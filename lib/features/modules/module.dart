import '../../core/errors/content_exception.dart';

/// A learning module — a themed group of lessons (FR-04). Lessons reference
/// their parent through `moduleId`, so [id] is part of the content data
/// contract and must stay stable after release (§18 persistence rule).
class Module {
  const Module({
    required this.id,
    required this.order,
    required this.title,
    required this.summary,
    required this.iconKey,
  });

  final String id;
  final int order;
  final String title;
  final String summary;

  /// Logical icon name resolved to a Material icon in the UI layer.
  final String iconKey;

  factory Module.fromJson(Map<String, dynamic> json) {
    String requireString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw ContentException(
          'Module field "$key" is missing or empty',
          source: 'modules.json',
        );
      }
      return value;
    }

    final order = json['order'];
    if (order is! int) {
      throw const ContentException(
        'Module field "order" must be an integer',
        source: 'modules.json',
      );
    }

    return Module(
      id: requireString('id'),
      order: order,
      title: requireString('title'),
      summary: requireString('summary'),
      iconKey: requireString('icon'),
    );
  }
}
