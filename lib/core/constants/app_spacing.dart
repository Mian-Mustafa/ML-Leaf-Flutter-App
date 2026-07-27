import 'package:flutter/widgets.dart';

/// Spacing scale (4-pt base). Use these instead of ad-hoc numbers so vertical
/// rhythm and padding stay consistent across screens.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Common ready-made gaps for column/row children.
  static const gapXs = SizedBox(height: xs, width: xs);
  static const gapSm = SizedBox(height: sm, width: sm);
  static const gapMd = SizedBox(height: md, width: md);
  static const gapLg = SizedBox(height: lg, width: lg);
  static const gapXl = SizedBox(height: xl, width: xl);

  // Screen edge insets.
  static const EdgeInsets screen = EdgeInsets.all(md);
  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: md);
}

/// Corner-radius scale.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;

  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
}

/// Minimum accessible sizes (NFR-04). 48dp is the recommended Material touch
/// target; body content should never fall below these.
abstract final class AppSizes {
  static const double minTouchTarget = 48;
  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 32;
}
