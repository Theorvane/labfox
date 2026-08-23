import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/icon_size.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// One destination in a [WorkGrid].
@immutable
class WorkDestination {
  const WorkDestination({
    required this.icon,
    required this.label,
    required this.onTap,
    this.count,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Shown large beside the label. Null hides it — an unknown count must not
  /// read as zero.
  final int? count;
}

/// The account-level shortcuts, on the brand's navy ground.
///
/// A grid rather than a list of rows, and navy rather than white: the row-of-
/// coloured-tiles shape is the one every code-hosting client uses, and on a
/// white surface with neutral text this screen was indistinguishable from them.
/// Navy is what the mark sits on, so the first screen is where the app should
/// look like itself.
///
/// Two columns also earn their place: four destinations sit within thumb reach
/// instead of running down the page, and each has room to show its count where
/// a row could only append it.
class WorkGrid extends StatelessWidget {
  const WorkGrid({required this.title, required this.destinations, super.key});

  final String title;
  final List<WorkDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final roles = LabFoxTextRoles.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(
        LabFoxSpacing.md,
        LabFoxSpacing.md,
        LabFoxSpacing.md,
        LabFoxSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: LabFoxColors.navy,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(LabFoxRadius.lg),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: roles.sectionHeader.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: LabFoxSpacing.sm),
          // Fixed two columns rather than a responsive count: the four
          // destinations are a stable set, and reflowing them would move a
          // target the user has learned the position of.
          for (var row = 0; row < (destinations.length + 1) ~/ 2; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: LabFoxSpacing.sm),
              child: Row(
                children: [
                  for (var column = 0; column < 2; column++) ...[
                    if (column == 1) const SizedBox(width: LabFoxSpacing.sm),
                    Expanded(
                      child: row * 2 + column < destinations.length
                          ? _Tile(destinations[row * 2 + column])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.destination);

  final WorkDestination destination;

  @override
  Widget build(BuildContext context) {
    final roles = LabFoxTextRoles.of(context);
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(LabFoxRadius.md),
      child: InkWell(
        onTap: destination.onTap,
        borderRadius: BorderRadius.circular(LabFoxRadius.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: LabFoxSpacing.minTouchTarget + LabFoxSpacing.md,
          ),
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.sm + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      destination.icon,
                      size: LabFoxIconSize.md,
                      // The accent carries the glyph; navy carries the ground.
                      color: LabFoxColors.orangeLight,
                    ),
                    const Spacer(),
                    if (destination.count != null)
                      Text(
                        '${destination.count}',
                        style: roles.rowTitle.copyWith(color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(height: LabFoxSpacing.sm),
                Text(
                  destination.label,
                  style: roles.rowTitle.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
