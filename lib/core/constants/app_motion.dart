import 'package:flutter/animation.dart';

/// Motion tokens. Durations and easings are centralised so animations feel
/// like one system. Kept short and purposeful — motion should aid orientation,
/// never delay the learner (NFR-01: navigation should feel immediate).
abstract final class AppMotion {
  static const Duration instant = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);

  /// Splash brand pause before routing onward.
  static const Duration splash = Duration(milliseconds: 900);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve standard = Curves.easeOut;
  static const Curve decelerate = Curves.easeOutQuart;
}
