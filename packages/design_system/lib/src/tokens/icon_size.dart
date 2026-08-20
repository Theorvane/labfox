/// Icon-size scale.
///
/// Four steps cover the app: inline chip glyphs, metadata icons, row and tile
/// glyphs, action icons, and the large empty-state glyph. Sizes in between are
/// not part of the system.
abstract final class LabFoxIconSize {
  /// Glyphs inside pills and chips.
  static const double xs = 12;

  /// Inline metadata icons next to text (stars, locks, comment counts).
  static const double sm = 16;

  /// Leading row glyphs and launcher-tile glyphs.
  static const double md = 20;

  /// Standalone action icons (the Material default).
  static const double lg = 24;

  /// The empty-state glyph.
  static const double xl = 40;
}
