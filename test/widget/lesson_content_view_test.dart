import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlleaf/app/theme.dart';
import 'package:mlleaf/features/lessons/content_block.dart';
import 'package:mlleaf/features/lessons/widgets/lesson_content_view.dart';

/// Renders one of every content-block type to catch layout errors (e.g. the
/// unbounded-height class of bug) in the lesson reader.
void main() {
  final blocks = <ContentBlock>[
    const HeadingBlock(text: 'Section', level: 2),
    const ParagraphBlock(text: 'A paragraph of lesson text.'),
    const BulletsBlock(items: ['First point', 'Second point']),
    const NumberedBlock(items: ['Step one', 'Step two']),
    const FormulaBlock(expression: 'y-hat = f(X)', explanation: 'A mapping.'),
    const CodeBlock(language: 'python', code: 'x = 1\nprint(x)'),
    const TableBlock(headers: ['A', 'B'], rows: [
      ['1', '2'],
      ['3', '4'],
    ]),
    const CalloutBlock(variant: CalloutVariant.warning, text: 'Be careful.'),
    const DefinitionBlock(term: 'Model', source: 'ref', text: 'The learned result.'),
    const ImageBlock(
        asset: 'assets/images/foundations/fig01_supervised_overview.webp',
        caption: 'Figure 1.'),
  ];

  testWidgets('renders all content block types without layout errors',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: LessonContentView(blocks: blocks),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Section'), findsOneWidget);
    expect(find.text('A paragraph of lesson text.'), findsOneWidget);
    expect(find.byType(Table), findsOneWidget);
    expect(find.text('4'), findsOneWidget); // table cell content wraps in place
    expect(find.text('Be careful.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
