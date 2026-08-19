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

  static const light = LabFoxStatusColors(
    open: StatusColor(
      foreground: Color(0xFF1F8B4C),
      container: Color(0xFFE4F3E9),
    ),
    merged: StatusColor(
      foreground: Color(0xFF7C58D3),
      container: Color(0xFFEEE7FB),
    ),
    closed: StatusColor(
      foreground: Color(0xFFD1293D),
      container: Color(0xFFFBE4E4),
    ),
    running: StatusColor(
      foreground: Color(0xFF1F6FEB),
      container: Color(0xFFE3EDFD),
    ),
    pending: StatusColor(
      foreground: Color(0xFF6F6A63),
      container: Color(0xFFECE6DF),
    ),
    warning: StatusColor(
      foreground: Color(0xFFB9770A),
      container: Color(0xFFF7ECD6),
    ),
  );

  static const dark = LabFoxStatusColors(
    open: StatusColor(
      foreground: Color(0xFF40C271),
      container: Color(0xFF12291C),
    ),
    merged: StatusColor(
      foreground: Color(0xFFA98BEA),
      container: Color(0xFF221A38),
    ),
    closed: StatusColor(
      foreground: Color(0xFFF0616B),
      container: Color(0xFF2C1518),
    ),
    running: StatusColor(
      foreground: Color(0xFF5B9BFF),
      container: Color(0xFF12203C),
    ),
    pending: StatusColor(
      foreground: Color(0xFF9AA0AE),
      container: Color(0xFF1E2434),
    ),
    warning: StatusColor(
      foreground: Color(0xFFE4A93A),
      container: Color(0xFF2A2213),
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
