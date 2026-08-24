import 'package:flutter/material.dart';

import '../tokens/icon_size.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

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
    final roles = LabFoxTextRoles.of(context);
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
                  borderRadius: BorderRadius.circular(LabFoxRadius.sm),
                ),
                child: Icon(icon, size: LabFoxIconSize.md, color: Colors.white),
              ),
              const SizedBox(width: LabFoxSpacing.md),
              Expanded(child: Text(label, style: roles.rowTitle)),
              if (count != null) Text('$count', style: roles.meta),
            ],
          ),
        ),
      ),
    );
  }
}
