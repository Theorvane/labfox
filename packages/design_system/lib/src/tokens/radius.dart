/// Corner-radius scale, matching GitLab's.
///
/// Every rounded corner comes from here so shapes stay consistent; a literal
/// `BorderRadius.circular(13)` has no place to come from.
///
/// The values are GitLab's own: 2, 4, 8, 12, and full. A shape scale carries no
/// brand, so matching it costs nothing and makes the app sit in the same visual
/// world as the thing it is a client for — unlike colour, where copying
/// GitLab's values would make an unofficial client look like the official app.
///
/// This scale is tighter than the one it replaced (6, 9, 12, 14), whose
/// smallest corner was larger than GitLab's default and whose middle equalled
/// GitLab's largest.
abstract final class LabFoxRadius {
  /// Inline code spans, small inner surfaces.
  static const double xs = 2;

  /// Icon tiles and small chips. GitLab's default.
  static const double sm = 4;

  /// Buttons, inputs, menus.
  static const double md = 8;

  /// Cards and large surfaces.
  static const double lg = 12;

  /// Fully rounded pills and status chips.
  static const double pill = 999;
}
