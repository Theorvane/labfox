import 'package:flutter/material.dart';

import '../tokens/spacing.dart';
import '../tokens/status_colors.dart';

/// The lifecycle state of an issue or merge request.
///
/// Issues use [open] and [closed]; merge requests add [merged]. Kept in one
/// enum so a single badge serves both.
enum EntityState { open, closed, merged }

/// A state badge for an issue or merge request.
///
/// Pairs an icon with the label so state survives greyscale and colour
/// blindness — never colour alone. Merged is purple, matching GitLab, so it is
/// not mistaken for a plain close.
class StateBadge extends StatelessWidget {
  const StateBadge({required this.state, required this.label, super.key});

  final EntityState state;
  final String label;

  @override
  Widget build(BuildContext context) {
    final status = LabFoxStatusColors.of(context);
    final (icon, colors) = switch (state) {
      EntityState.open => (Icons.error_outline, status.open),
      EntityState.closed => (Icons.cancel_outlined, status.closed),
      EntityState.merged => (Icons.merge, status.merged),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LabFoxSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.foreground),
          const SizedBox(width: LabFoxSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: colors.foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
