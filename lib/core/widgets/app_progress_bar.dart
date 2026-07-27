import 'package:flutter/material.dart';

import '../constants/app_motion.dart';
import '../constants/app_spacing.dart';

/// A labelled, animated linear progress indicator (design system component
/// "Progress indicator": empty / partial / complete states).
///
/// Exposes a percentage in its semantic label and pairs the bar with a text
/// value so progress is not conveyed by the bar alone.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.label,
    this.showPercent = true,
  }) : assert(value >= 0 && value <= 1);

  /// 0.0–1.0.
  final double value;
  final String? label;
  final bool showPercent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (value * 100).round();
    final complete = value >= 1.0;

    return Semantics(
      label: label == null ? 'Progress' : '$label progress',
      value: '$percent percent',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null || showPercent)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (label != null)
                    Text(label!, style: theme.textTheme.labelMedium)
                  else
                    const SizedBox.shrink(),
                  if (showPercent)
                    Text(
                      complete ? 'Complete' : '$percent%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: complete
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ClipRRect(
            borderRadius: AppRadius.brSm,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value),
              duration: AppMotion.slow,
              curve: AppMotion.decelerate,
              builder: (context, animatedValue, _) => LinearProgressIndicator(
                value: animatedValue,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor:
                    AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
