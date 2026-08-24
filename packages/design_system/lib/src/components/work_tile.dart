import 'package:flutter/material.dart';

import '../tokens/icon_size.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// A dense list row for a unit of work — an issue, merge request, to-do, or
/// search hit.
///
/// A leading status glyph, a two-line title, and a wrap of caller-supplied
/// [metadata] widgets (pills, numbers, repo, avatar). One row shape across the
/// app so every list reads the same and a change lands everywhere at once.
class WorkTile extends StatelessWidget {
  const WorkTile({
    required this.icon,
    required this.title,
    this.contextLabel,
    this.iconColor,
    this.metadata = const [],
    this.trailing,
    this.onTap,
    super.key,
  });

  final IconData icon;

  /// Tint for the leading glyph — usually a status foreground. Falls back to a
  /// muted colour.
  final Color? iconColor;

  /// Project or namespace context shown above the primary title.
  ///
  /// Account-level lists use this to keep the item's origin visible without
  /// mixing it into identifiers and status metadata.
  final String? contextLabel;

  final String title;

  /// Chips and labels shown under the title. Wraps to a second run when needed.
  final List<Widget> metadata;

  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roles = LabFoxTextRoles.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LabFoxSpacing.md,
          vertical: LabFoxSpacing.sm + LabFoxSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contextLabel != null) ...[
              Padding(
                padding: const EdgeInsets.only(
                  left: LabFoxIconSize.md + LabFoxSpacing.sm,
                ),
                child: Text(
                  contextLabel!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: roles.meta,
                ),
              ),
              const SizedBox(height: LabFoxSpacing.xs),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: LabFoxSpacing.sm),
                  child: Icon(
                    icon,
                    size: LabFoxIconSize.md,
                    color: iconColor ?? theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: roles.rowTitle,
                      ),
                      if (metadata.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: LabFoxSpacing.xs),
                          child: DefaultTextStyle.merge(
                            style: roles.meta,
                            child: Wrap(
                              spacing: LabFoxSpacing.sm,
                              runSpacing: LabFoxSpacing.xs,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: metadata,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(left: LabFoxSpacing.sm),
                    child: trailing,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
