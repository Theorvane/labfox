/// Spacing scale.
///
/// Every gap in the app comes from here so density stays consistent; a literal
/// `EdgeInsets.all(13)` has no place to come from.
abstract final class LabFoxSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Minimum touch target. Below this, targets fail accessibility guidance on
  /// both platforms.
  static const double minTouchTarget = 44;
}
