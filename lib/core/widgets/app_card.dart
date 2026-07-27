import 'package:flutter/material.dart';

import '../constants/app_motion.dart';
import '../constants/app_spacing.dart';

/// A themed surface card. When [onTap] is provided it gains ink feedback and a
/// subtle press-scale (design system: "pressed" state for cards), and exposes a
/// button semantics node for screen readers.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.accentColor,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// When set, a thin leading accent bar is drawn (used to convey status
  /// alongside an icon or label — never colour alone).
  final Color? accentColor;
  final String? semanticLabel;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;

    Widget content = Padding(padding: widget.padding, child: widget.child);

    if (widget.accentColor != null) {
      // IntrinsicHeight gives the stretched accent bar a bounded height so it
      // matches the content height instead of trying to fill infinity.
      content = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: widget.accentColor),
            Expanded(child: content),
          ],
        ),
      );
    }

    Widget card = Card(
      clipBehavior: Clip.antiAlias,
      child: interactive
          ? InkWell(
              onTap: widget.onTap,
              onTapDown: (_) => _setPressed(true),
              onTapUp: (_) => _setPressed(false),
              onTapCancel: () => _setPressed(false),
              borderRadius: AppRadius.brLg,
              child: content,
            )
          : content,
    );

    if (interactive) {
      card = AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: AppMotion.instant,
        curve: AppMotion.standard,
        child: card,
      );
      // When an explicit label is given, present the card as a single button
      // node and suppress the inner nodes so screen readers read it once.
      if (widget.semanticLabel != null) {
        card = Semantics(
          button: true,
          label: widget.semanticLabel,
          child: ExcludeSemantics(child: card),
        );
      }
    }

    return card;
  }
}
