import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';

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
    final (icon, color) = switch (state) {
      EntityState.open => (Icons.error_outline, LabFoxColors.success),
      EntityState.closed => (Icons.cancel_outlined, LabFoxColors.failure),
      EntityState.merged => (Icons.merge, const Color(0xFF6E49CB)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LabFoxSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: LabFoxSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
