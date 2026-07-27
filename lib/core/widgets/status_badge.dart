import 'package:flutter/material.dart';

import '../../app/semantic_colors.dart';
import '../constants/app_spacing.dart';

/// Semantic tone for a [StatusBadge].
enum BadgeTone { neutral, info, success, warning, danger }

/// A small pill combining an icon and label. Always shows text, so status is
/// never communicated by colour alone (accessibility checklist §13.8).
///
/// Used for difficulty, completion and review states across lesson/module/quiz
/// cards.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.tone = BadgeTone.neutral,
  });

  final String label;
  final IconData? icon;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semantic;

    final (Color bg, Color fg) = switch (tone) {
      BadgeTone.neutral => (
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.onSurfaceVariant,
        ),
      // Use the darker on-container green (not `primary`) so small badge text
      // clears WCAG AA 4.5:1 on the light-green container.
      BadgeTone.info => (
          semantic.infoContainer,
          theme.colorScheme.onPrimaryContainer,
        ),
      BadgeTone.success => (semantic.successContainer, semantic.onSuccessContainer),
      BadgeTone.warning => (semantic.warningContainer, semantic.onWarningContainer),
      BadgeTone.danger => (
          theme.colorScheme.errorContainer,
          theme.colorScheme.onErrorContainer,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.brSm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
