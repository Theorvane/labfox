import 'package:flutter/material.dart';

import '../tokens/spacing.dart';

/// A dropdown filter chip: a stadium chip showing the selected value with a
/// caret, opening a menu of options when tapped.
///
/// One chip per filter dimension, laid out in a horizontally scrolling row —
/// each dimension reads and changes independently, unlike a segmented control
/// that must show every option at once.
class FilterMenuChip<T> extends StatelessWidget {
  const FilterMenuChip({
    required this.selected,
    required this.options,
    required this.labelOf,
    required this.onSelected,
    super.key,
  });

  /// The currently selected value, shown on the chip.
  final T selected;

  final List<T> options;

  /// Maps a value to its visible label.
  final String Function(T value) labelOf;

  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<T>(
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final option in options)
          CheckedPopupMenuItem(
            value: option,
            checked: option == selected,
            child: Text(labelOf(option)),
          ),
      ],
      child: Container(
        constraints: const BoxConstraints(
          minHeight: LabFoxSpacing.minTouchTarget,
        ),
        padding: const EdgeInsets.only(
          left: LabFoxSpacing.md,
          right: LabFoxSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              labelOf(selected),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
