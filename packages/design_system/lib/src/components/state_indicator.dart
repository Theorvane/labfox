import 'package:flutter/material.dart';

import '../tokens/spacing.dart';
import '../tokens/status_colors.dart';

/// What a pipeline, job or merge request is currently doing.
enum LabFoxState { success, failure, running, pending, warning }

/// Shows a status as an icon, a colour and a label together.
///
/// Colour alone is never the signal. Pipeline pass and fail are the most
/// consequential states in the app, and red/green is exactly the pair that
/// disappears for the most common form of colour blindness.
class StateIndicator extends StatelessWidget {
  const StateIndicator({
    required this.state,
    required this.label,
    this.compact = false,
    super.key,
  });

  final LabFoxState state;
  final String label;

  /// Drops the text and keeps the icon, for dense rows. The label still ships
  /// as a semantic label so screen readers are unaffected.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final status = LabFoxStatusColors.of(context);
    final (icon, color) = switch (state) {
      LabFoxState.success => (
        Icons.check_circle_outline,
        status.open.foreground,
      ),
      LabFoxState.failure => (Icons.cancel_outlined, status.closed.foreground),
      LabFoxState.running => (
        Icons.play_circle_outline,
        status.running.foreground,
      ),
      LabFoxState.pending => (Icons.circle_outlined, status.pending.foreground),
      LabFoxState.warning => (Icons.error_outline, status.warning.foreground),
    };

    return Semantics(
      label: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
            semanticLabel: compact ? label : null,
          ),
          if (!compact) ...[
            const SizedBox(width: LabFoxSpacing.xs),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ],
      ),
    );
  }
}
