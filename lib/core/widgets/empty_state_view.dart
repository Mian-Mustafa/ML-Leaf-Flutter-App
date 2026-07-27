import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';

/// A friendly empty/placeholder state: soft icon medallion, title, explanation
/// and an optional next-step action (design system components "Empty state" and
/// "Error state" — always give a clear explanation and a next action).
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.tone = EmptyStateTone.neutral,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyStateTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isError = tone == EmptyStateTone.error;
    final accent =
        isError ? theme.colorScheme.error : theme.colorScheme.primary;
    final medallionBg = isError
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.primaryContainer;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: medallionBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: AppSizes.iconLg + 8, color: accent),
            ),
            AppSpacing.gapLg,
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              AppSpacing.gapXs,
              Text(
                message!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.gapLg,
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

enum EmptyStateTone { neutral, error }
