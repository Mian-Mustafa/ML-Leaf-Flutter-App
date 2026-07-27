import 'package:flutter/material.dart';

import '../constants/app_motion.dart';

/// Animated bookmark toggle (design system component "Bookmark control":
/// saved / unsaved). Provides an accessible label and a springy scale when the
/// state changes.
class BookmarkButton extends StatelessWidget {
  const BookmarkButton({
    super.key,
    required this.saved,
    required this.onToggle,
  });

  final bool saved;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      tooltip: saved ? 'Remove bookmark' : 'Add bookmark',
      onPressed: onToggle,
      icon: AnimatedSwitcher(
        duration: AppMotion.fast,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        ),
        child: Icon(
          saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
          key: ValueKey(saved),
          color: saved
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
