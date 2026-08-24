import 'package:flutter/material.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';

/// An icon + optional label for a CI/CD status, shared by pipelines and jobs.
///
/// Status is never colour alone: each maps to a distinct icon as well, so the
/// meaning survives greyscale and colour blindness. A running status is the one
/// most worth distinguishing at a glance, and failed is the case users open
/// for.
class CiStatusIcon extends StatelessWidget {
  const CiStatusIcon({required this.status, this.label, super.key});

  final CiStatus status;

  /// When given, shown next to the icon; the caller localizes it.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _visual(status);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color, semanticLabel: label),
        if (label != null) ...[
          const SizedBox(width: LabFoxSpacing.xs),
          Text(
            label!,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  static (IconData, Color) _visual(CiStatus status) => switch (status) {
    CiStatus.success => (Icons.check_circle, LabFoxColors.success),
    CiStatus.failed => (Icons.cancel, LabFoxColors.failure),
    CiStatus.running => (Icons.autorenew, LabFoxColors.running),
    CiStatus.pending => (Icons.schedule, LabFoxColors.warning),
    CiStatus.canceled => (Icons.block, LabFoxColors.pending),
    CiStatus.skipped => (Icons.skip_next, LabFoxColors.pending),
    CiStatus.manual => (Icons.play_circle_outline, LabFoxColors.pending),
    CiStatus.created => (Icons.fiber_new_outlined, LabFoxColors.pending),
    CiStatus.other => (Icons.help_outline, LabFoxColors.pending),
  };
}
