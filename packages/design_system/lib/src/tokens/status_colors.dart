import 'package:flutter/material.dart';

/// A foreground / container colour pair for one status.
///
/// [foreground] is the icon and text colour; [container] is the soft pill
/// background behind it. Pairing them means a pill reads with proper contrast
/// on either theme instead of alpha-blending a single colour onto the surface,
/// which turns muddy on dark.
@immutable
class StatusColor {
  const StatusColor({required this.foreground, required this.container});

  final Color foreground;
  final Color container;

  StatusColor lerp(StatusColor other, double t) => StatusColor(
    foreground: Color.lerp(foreground, other.foreground, t)!,
    container: Color.lerp(container, other.container, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is StatusColor &&
      other.foreground == foreground &&
      other.container == container;

  @override
  int get hashCode => Object.hash(foreground, container);
}

/// Semantic status colours, resolved from the active theme.
///
/// Status hues are deliberately separate from the LabFox orange accent, which
/// is reserved for interactive elements. Colour is never the only signal —
/// every use pairs a status colour with an icon and a label — but these tokens
/// give each status one consistent, theme-aware appearance across the app.
@immutable
class LabFoxStatusColors extends ThemeExtension<LabFoxStatusColors> {
  const LabFoxStatusColors({
    required this.open,
    required this.merged,
    required this.closed,
    required this.running,
    required this.pending,
    required this.warning,
  });

  /// Open issue / merge request, and a passed pipeline.
  final StatusColor open;

  /// Merged merge request — violet, never mistaken for a plain close.
  final StatusColor merged;

  /// Closed issue / merge request, and a failed pipeline.
  final StatusColor closed;

  /// A pipeline or job in progress.
  final StatusColor running;

  /// Queued or manual, not yet started.
  final StatusColor pending;

  /// A warning — a pipeline that passed with issues, a stuck state.
  final StatusColor warning;

  /// The palette for the current theme.
  static LabFoxStatusColors of(BuildContext context) =>
      Theme.of(context).extension<LabFoxStatusColors>() ?? light;

  // Paper (light): crisp, high-contrast hues on white, with a subtle tinted
  // container for chips.
  static const light = LabFoxStatusColors(
    open: StatusColor(
      foreground: Color(0xFF1A7F37),
      container: Color(0xFFE9F6EC),
    ),
    merged: StatusColor(
      foreground: Color(0xFF8250DF),
      container: Color(0xFFF1EBFC),
    ),
    closed: StatusColor(
      foreground: Color(0xFFCF222E),
      container: Color(0xFFFCEBEC),
    ),
    running: StatusColor(
      foreground: Color(0xFF0969DA),
      container: Color(0xFFE7F0FC),
    ),
    pending: StatusColor(
      foreground: Color(0xFF6E7781),
      container: Color(0xFFF0F1F3),
    ),
    warning: StatusColor(
      foreground: Color(0xFF9A6700),
      container: Color(0xFFFBF3E2),
    ),
  );

  // Graphite (dark): brighter hues for contrast on near-black, deep tinted
  // containers.
  static const dark = LabFoxStatusColors(
    open: StatusColor(
      foreground: Color(0xFF3FB950),
      container: Color(0xFF12261A),
    ),
    merged: StatusColor(
      foreground: Color(0xFFA371F7),
      container: Color(0xFF211A33),
    ),
    closed: StatusColor(
      foreground: Color(0xFFF85149),
      container: Color(0xFF2A1719),
    ),
    running: StatusColor(
      foreground: Color(0xFF4C9EFF),
      container: Color(0xFF10233D),
    ),
    pending: StatusColor(
      foreground: Color(0xFF7D8590),
      container: Color(0xFF1B1F27),
    ),
    warning: StatusColor(
      foreground: Color(0xFFD9A441),
      container: Color(0xFF241E12),
    ),
  );

  @override
  LabFoxStatusColors copyWith({
    StatusColor? open,
    StatusColor? merged,
    StatusColor? closed,
    StatusColor? running,
    StatusColor? pending,
    StatusColor? warning,
  }) {
    return LabFoxStatusColors(
      open: open ?? this.open,
      merged: merged ?? this.merged,
      closed: closed ?? this.closed,
      running: running ?? this.running,
      pending: pending ?? this.pending,
      warning: warning ?? this.warning,
    );
  }

  @override
  LabFoxStatusColors lerp(ThemeExtension<LabFoxStatusColors>? other, double t) {
    if (other is! LabFoxStatusColors) {
      return this;
    }
    return LabFoxStatusColors(
      open: open.lerp(other.open, t),
      merged: merged.lerp(other.merged, t),
      closed: closed.lerp(other.closed, t),
      running: running.lerp(other.running, t),
      pending: pending.lerp(other.pending, t),
      warning: warning.lerp(other.warning, t),
    );
  }
}
