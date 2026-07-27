import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';

/// A consistent section title with an optional trailing action (e.g. "See all").
/// Marked as a semantic header for screen-reader navigation.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.action,
    this.padding = const EdgeInsets.only(bottom: AppSpacing.sm),
  });

  final String title;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
