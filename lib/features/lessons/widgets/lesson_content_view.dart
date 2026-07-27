import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';

import '../../../app/semantic_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../content_block.dart';

/// Renders a lesson's structured content blocks into a professional reading
/// layout (FR-05). Figures, tables, callouts, formulas, definitions and code
/// each have a dedicated, theme-aware presentation.
class LessonContentView extends StatelessWidget {
  const LessonContentView({super.key, required this.blocks});

  final List<ContentBlock> blocks;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final previous = i == 0 ? null : blocks[i - 1];
      children.add(SizedBox(height: _gapBefore(previous, block)));
      children.add(_buildBlock(context, block));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  /// Contextual vertical rhythm: content hugs the heading it belongs to, new
  /// sections get a clear break, and card-like blocks (figure, table, code,
  /// callout, definition, formula) breathe a little more than plain text.
  static double _gapBefore(ContentBlock? previous, ContentBlock current) {
    if (previous == null) return 0;
    if (previous is HeadingBlock) return AppSpacing.sm;
    if (current is HeadingBlock) {
      return current.level <= 2 ? AppSpacing.xl : AppSpacing.lg;
    }
    if (_isCard(previous) || _isCard(current)) return AppSpacing.lg;
    return AppSpacing.md;
  }

  static bool _isCard(ContentBlock b) =>
      b is ImageBlock ||
      b is TableBlock ||
      b is CodeBlock ||
      b is CalloutBlock ||
      b is DefinitionBlock ||
      b is FormulaBlock;

  Widget _buildBlock(BuildContext context, ContentBlock block) {
    return switch (block) {
      HeadingBlock b => _Heading(b),
      ParagraphBlock b => _Paragraph(b),
      BulletsBlock b => _MarkerList(items: b.items, ordered: false),
      NumberedBlock b => _MarkerList(items: b.items, ordered: true),
      ImageBlock b => _Figure(b),
      FormulaBlock b => _Formula(b),
      CodeBlock b => _Code(b),
      TableBlock b => _Table(b),
      CalloutBlock b => _Callout(b),
      DefinitionBlock b => _Definition(b),
    };
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.block);
  final HeadingBlock block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Level 1-2: a highlighted section band so read-notes sections stand out.
    if (block.level <= 2) {
      return Semantics(
        header: true,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: AppRadius.brMd,
            border: Border(
              left: BorderSide(color: theme.colorScheme.primary, width: 4),
            ),
          ),
          child: Text(
            block.text,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    // Level 3+: a lighter accent-bar subheading.
    return Semantics(
      header: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 3,
            height: 18,
            margin: const EdgeInsets.only(right: AppSpacing.xs),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: AppRadius.brSm,
            ),
          ),
          Expanded(
            child: Text(block.text, style: theme.textTheme.titleSmall),
          ),
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.block);
  final ParagraphBlock block;

  @override
  Widget build(BuildContext context) {
    return Text(block.text, style: Theme.of(context).textTheme.bodyLarge);
  }
}

class _MarkerList extends StatelessWidget {
  const _MarkerList({required this.items, required this.ordered});
  final List<String> items;
  final bool ordered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ordered)
                  _NumberMarker(i + 1)
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: AppSpacing.sm),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(items[i], style: theme.textTheme.bodyLarge),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _NumberMarker extends StatelessWidget {
  const _NumberMarker(this.n);
  final int n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(right: AppSpacing.sm, top: 1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$n',
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// A figure: the diagram/graph is always shown on a white surface (the source
/// images are designed on white) so it reads correctly in light and dark, with
/// a caption below and tap-to-zoom for detail.
class _Figure extends StatelessWidget {
  const _Figure(this.block);
  final ImageBlock block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          image: true,
          label: block.caption ?? 'Figure',
          child: GestureDetector(
            onTap: () => _openZoom(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.brLg,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Image.asset(block.asset, fit: BoxFit.contain),
            ),
          ),
        ),
        if (block.caption != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(Icons.image_outlined,
                  size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  block.caption!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _openZoom(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, _, _) => _ImageZoom(asset: block.asset, caption: block.caption),
      ),
    );
  }
}

class _ImageZoom extends StatelessWidget {
  const _ImageZoom({required this.asset, this.caption});
  final String asset;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.brMd,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(asset, fit: BoxFit.contain),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Close',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Formula extends StatelessWidget {
  const _Formula(this.block);
  final FormulaBlock block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SelectableText(
            block.expression,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'monospace',
              color: theme.colorScheme.primary,
            ),
          ),
          if (block.explanation != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              block.explanation!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _Code extends StatelessWidget {
  const _Code(this.block);
  final CodeBlock block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final codeBg = isDark ? const Color(0xFF282C34) : const Color(0xFFF6F8FA);
    final headerBg = isDark ? const Color(0xFF21252B) : const Color(0xFFEDF1F5);
    final headerFg = isDark
        ? const Color(0xFF9DA5B4)
        : theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.brMd,
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.brMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Language header bar.
                Container(
                  color: headerBg,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      Icon(Icons.code_rounded, size: 14, color: headerFg),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        block.language.toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: headerFg,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Code body.
                Container(
                  width: double.infinity,
                  color: codeBg,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: HighlightView(
                      block.code,
                      language: block.language,
                      theme: isDark ? atomOneDarkTheme : githubTheme,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      textStyle:
                          const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.45),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (block.explanation != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: Text(
              block.explanation!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ],
    );
  }
}

class _Table extends StatelessWidget {
  const _Table(this.block);
  final TableBlock block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final zebra =
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);
    final cols = block.headers.length;

    // Fit the table to the available width and let cells wrap, instead of
    // scrolling sideways (which clips text off-screen on a phone). The first
    // column is a little narrower since it holds short labels.
    final columnWidths = <int, TableColumnWidth>{
      0: const FlexColumnWidth(1),
      for (var i = 1; i < cols; i++) i: const FlexColumnWidth(1.35),
    };

    Widget cell(String text, {required bool header, required bool emphasize}) {
      final TextStyle? style = header
          ? theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            )
          : emphasize
              ? theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                )
              : theme.textTheme.bodySmall;
      return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        child: Text(text, style: style),
      );
    }

    return ClipRRect(
      borderRadius: AppRadius.brMd,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
          borderRadius: AppRadius.brMd,
        ),
        child: Table(
          columnWidths: columnWidths,
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          border: TableBorder(
            horizontalInside: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: 0.5,
            ),
          ),
          children: [
            TableRow(
              decoration:
                  BoxDecoration(color: theme.colorScheme.primaryContainer),
              children: [
                for (final h in block.headers)
                  cell(h, header: true, emphasize: false),
              ],
            ),
            for (var r = 0; r < block.rows.length; r++)
              TableRow(
                decoration: BoxDecoration(
                    color: r.isOdd ? zebra : Colors.transparent),
                children: [
                  for (var i = 0; i < cols; i++)
                    cell(
                      i < block.rows[r].length ? block.rows[r][i] : '',
                      header: false,
                      emphasize: i == 0,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout(this.block);
  final CalloutBlock block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semantic;

    final (Color bg, Color accent, IconData icon, String fallbackTitle) =
        switch (block.variant) {
      CalloutVariant.tip => (
          semantic.successContainer,
          semantic.onSuccessContainer,
          Icons.lightbulb_outline_rounded,
          'Tip',
        ),
      CalloutVariant.warning => (
          semantic.warningContainer,
          semantic.onWarningContainer,
          Icons.warning_amber_rounded,
          'Caution',
        ),
      CalloutVariant.quickCheck => (
          theme.colorScheme.primaryContainer,
          theme.colorScheme.onPrimaryContainer,
          Icons.help_outline_rounded,
          'Quick check',
        ),
      CalloutVariant.note => (
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.primary,
          Icons.info_outline_rounded,
          'Note',
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.brMd,
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: AppSpacing.xs),
              Text(
                block.title ?? fallbackTitle,
                style: theme.textTheme.titleSmall?.copyWith(color: accent),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            block.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.brightness == Brightness.light
                  ? theme.colorScheme.onSurface
                  : accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _Definition extends StatelessWidget {
  const _Definition(this.block);
  final DefinitionBlock block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.brMd,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded,
                  size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(block.term,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: theme.colorScheme.primary)),
              ),
              if (block.source != null)
                Text(block.source!, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(block.text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
