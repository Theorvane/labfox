import 'package:flutter/material.dart';

import '../tokens/spacing.dart';
import '../tokens/status_colors.dart';

/// A soft status chip — a rounded pill filled with a status container colour,
/// its label (and optional dot or icon) in the matching foreground.
///
/// This is the redesign's state marker: open / merged / closed / running and
/// so on. Colour is never the only signal — the label carries the meaning — so
/// a dot or icon is optional emphasis, not a replacement for words.
class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.label,
    required this.colors,
    this.icon,
    this.dot = false,
    super.key,
  });

  final String label;

  /// The foreground / container pair, usually from
  /// `LabFoxStatusColors.of(context)`.
  final StatusColor colors;

  /// An optional leading icon, in the foreground colour.
  final IconData? icon;

  /// A small leading dot in the foreground colour. Ignored when [icon] is set.
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LabFoxSpacing.sm,
          vertical: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(icon, size: 12, color: colors.foreground),
              )
            else if (dot)
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.foreground,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(width: 7, height: 7),
                ),
              ),
            Text(
              label,
              style: TextStyle(
                color: colors.foreground,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
