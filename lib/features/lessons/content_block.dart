import '../../core/errors/content_exception.dart';

/// A single renderable block in a lesson body (documentation plan §17.1:
/// "content: structured blocks"). Modelled as a sealed hierarchy so the reader
/// can switch over every supported block type exhaustively.
sealed class ContentBlock {
  const ContentBlock();

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    switch (type) {
      case 'heading':
        return HeadingBlock(
          text: _str(json, 'text'),
          level: (json['level'] as num?)?.toInt() ?? 2,
        );
      case 'paragraph':
        return ParagraphBlock(text: _str(json, 'text'));
      case 'bullets':
        return BulletsBlock(items: _strList(json, 'items'));
      case 'numbered':
        return NumberedBlock(items: _strList(json, 'items'));
      case 'image':
        return ImageBlock(
          asset: _str(json, 'asset'),
          caption: json['caption'] as String?,
        );
      case 'formula':
        return FormulaBlock(
          expression: _str(json, 'expression'),
          explanation: json['explanation'] as String?,
        );
      case 'code':
        return CodeBlock(
          language: json['language'] as String? ?? 'python',
          code: _str(json, 'code'),
          explanation: json['explanation'] as String?,
        );
      case 'table':
        return TableBlock(
          headers: _strList(json, 'headers'),
          rows: _rows(json),
        );
      case 'callout':
        return CalloutBlock(
          variant: CalloutVariant.fromKey(json['variant'] as String?),
          title: json['title'] as String?,
          text: _str(json, 'text'),
        );
      case 'definition':
        return DefinitionBlock(
          term: _str(json, 'term'),
          source: json['source'] as String?,
          text: _str(json, 'text'),
        );
      default:
        throw ContentException('Unknown content block type "$type"');
    }
  }
}

class HeadingBlock extends ContentBlock {
  const HeadingBlock({required this.text, this.level = 2});
  final String text;
  final int level;
}

class ParagraphBlock extends ContentBlock {
  const ParagraphBlock({required this.text});
  final String text;
}

class BulletsBlock extends ContentBlock {
  const BulletsBlock({required this.items});
  final List<String> items;
}

class NumberedBlock extends ContentBlock {
  const NumberedBlock({required this.items});
  final List<String> items;
}

class ImageBlock extends ContentBlock {
  const ImageBlock({required this.asset, this.caption});
  final String asset;
  final String? caption;
}

class FormulaBlock extends ContentBlock {
  const FormulaBlock({required this.expression, this.explanation});
  final String expression;
  final String? explanation;
}

class CodeBlock extends ContentBlock {
  const CodeBlock({required this.language, required this.code, this.explanation});
  final String language;
  final String code;
  final String? explanation;
}

class TableBlock extends ContentBlock {
  const TableBlock({required this.headers, required this.rows});
  final List<String> headers;
  final List<List<String>> rows;
}

enum CalloutVariant {
  note,
  tip,
  warning,
  quickCheck;

  static CalloutVariant fromKey(String? key) {
    switch (key) {
      case 'tip':
        return CalloutVariant.tip;
      case 'warning':
        return CalloutVariant.warning;
      case 'quick_check':
      case 'quickcheck':
        return CalloutVariant.quickCheck;
      default:
        return CalloutVariant.note;
    }
  }
}

class CalloutBlock extends ContentBlock {
  const CalloutBlock({required this.variant, required this.text, this.title});
  final CalloutVariant variant;
  final String? title;
  final String text;
}

class DefinitionBlock extends ContentBlock {
  const DefinitionBlock({required this.term, required this.text, this.source});
  final String term;
  final String? source;
  final String text;
}

// --- parsing helpers -------------------------------------------------------

String _str(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw ContentException('Block field "$key" is missing or empty');
  }
  return value;
}

List<String> _strList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List || value.isEmpty) {
    throw ContentException('Block field "$key" must be a non-empty list');
  }
  return value.map((e) => e.toString()).toList();
}

List<List<String>> _rows(Map<String, dynamic> json) {
  final value = json['rows'];
  if (value is! List) {
    throw ContentException('Table field "rows" must be a list');
  }
  return value
      .map((r) => (r as List).map((c) => c.toString()).toList())
      .toList();
}
