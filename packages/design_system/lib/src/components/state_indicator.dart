import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';

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
    final (icon, color) = switch (state) {
      LabFoxState.success => (Icons.check_circle_outline, LabFoxColors.success),
      LabFoxState.failure => (Icons.cancel_outlined, LabFoxColors.failure),
      LabFoxState.running => (Icons.play_circle_outline, LabFoxColors.running),
      LabFoxState.pending => (Icons.circle_outlined, LabFoxColors.pending),
      LabFoxState.warning => (Icons.error_outline, LabFoxColors.warning),
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
