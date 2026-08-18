import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';

/// An open/closed badge for an issue or merge request.
///
/// Pairs an icon with the label so state survives greyscale and colour
/// blindness — never colour alone.
class IssueStateBadge extends StatelessWidget {
  const IssueStateBadge({required this.isOpen, required this.label, super.key});

  final bool isOpen;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? LabFoxColors.success : LabFoxColors.failure;
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
          Icon(
            isOpen ? Icons.error_outline : Icons.check_circle_outline,
            size: 14,
            color: color,
          ),
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
