import 'package:flutter/material.dart';

import '../tokens/spacing.dart';

/// A flat launcher row: a filled colour tile with an icon, a label, and an
/// optional trailing count — the shortcut shape the Home "My work" section and
/// the project overview categories share. Deliberately flat: no card, no
/// chevron.
class LauncherTile extends StatelessWidget {
  const LauncherTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.count,
    super.key,
  });

  final IconData icon;

  /// The tile's background colour; the glyph is always white on top of it.
  final Color color;

  final String label;
  final VoidCallback onTap;

  /// Shown after the label, right-aligned. Null hides it — an unknown count
  /// must not read as zero.
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: LabFoxSpacing.minTouchTarget,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LabFoxSpacing.md,
            vertical: LabFoxSpacing.sm + 2,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 19, color: Colors.white),
              ),
              const SizedBox(width: LabFoxSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (count != null)
                Text(
                  '$count',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
