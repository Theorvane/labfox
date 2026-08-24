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

  /// Merged merge request — informational, never mistaken for a plain close.
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
      foreground: Color(0xFF0E593C),
      container: Color(0xFFEBF7F2),
    ),
    merged: StatusColor(
      foreground: Color(0xFF0F637B),
      container: Color(0xFFEBF5F7),
    ),
    closed: StatusColor(
      foreground: Color(0xFF4F0D16),
      container: Color(0xFFF7EBEC),
    ),
    running: StatusColor(
      foreground: Color(0xFF1E3879),
      container: Color(0xFFEBEEF7),
    ),
    pending: StatusColor(
      foreground: Color(0xFF6A645E),
      container: Color(0xFFF2F1F0),
    ),
    warning: StatusColor(
      foreground: Color(0xFF916300),
      container: Color(0xFFF7F3EB),
    ),
  );

  // Graphite (dark): brighter hues for contrast on near-black, deep tinted
  // containers.
  static const dark = LabFoxStatusColors(
    open: StatusColor(
      foreground: Color(0xFF1FBD80),
      container: Color(0xFF10281F),
    ),
    merged: StatusColor(
      foreground: Color(0xFF40C3E7),
      container: Color(0xFF102328),
    ),
    closed: StatusColor(
      foreground: Color(0xFFE24B5F),
      container: Color(0xFF281013),
    ),
    running: StatusColor(
      foreground: Color(0xFF7693DD),
      container: Color(0xFF101728),
    ),
    pending: StatusColor(
      foreground: Color(0xFFC7C3BF),
      container: Color(0xFF1E1C1A),
    ),
    warning: StatusColor(
      foreground: Color(0xFFFFCD62),
      container: Color(0xFF282010),
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
