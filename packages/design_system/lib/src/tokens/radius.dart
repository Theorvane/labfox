/// Corner-radius scale.
///
/// Every rounded corner comes from here so shapes stay consistent; a literal
/// `BorderRadius.circular(13)` has no place to come from.
abstract final class LabFoxRadius {
  /// Inline code spans, small inner surfaces.
  static const double xs = 6;

  /// Icon tiles and small chips.
  static const double sm = 9;

  /// Buttons, inputs, menus.
  static const double md = 12;

  /// Cards and large surfaces.
  static const double lg = 14;

  /// Fully rounded pills and status chips.
  static const double pill = 999;
}
