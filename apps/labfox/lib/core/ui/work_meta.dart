import 'package:flutter/material.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Muted, tabular metadata text for a work row — an IID, an author, a date.
class MetaText extends StatelessWidget {
  const MetaText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.hintColor,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// A comment count with a small speech icon; renders nothing when zero.
class CommentCount extends StatelessWidget {
  const CommentCount(this.count, {super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.mode_comment_outlined, size: 13, color: theme.hintColor),
        const SizedBox(width: 3),
        Text(
          '$count',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        ),
      ],
    );
  }
}

/// Full colour label chips — the label name on its own colour, the way GitLab
/// and GitHub render labels — capped at [max] with a `+N` overflow so a heavily
/// labelled row stays bounded. The chips wrap within a row's metadata [Wrap].
class LabelChips extends StatelessWidget {
  const LabelChips(this.labels, {this.max = 3, super.key});

  final List<Label> labels;
  final int max;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }
    final shown = labels.take(max).toList(growable: false);
    final extra = labels.length - shown.length;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final label in shown) _Chip(label: label),
        if (extra > 0) MetaText('+$extra'),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final Label label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background =
        _hexColor(label.color) ?? theme.colorScheme.surfaceContainerHighest;
    // Prefer the colour GitLab supplies; otherwise pick black/white for contrast
    // against the background so the name stays readable on any label colour.
    final foreground =
        _hexColor(label.textColor) ??
        (background.computeLuminance() > 0.5 ? Colors.black : Colors.white);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Parses a `#rrggbb` (or `rrggbb`) hex string to a [Color], or null.
Color? _hexColor(String? value) {
  if (value == null) {
    return null;
  }
  var hex = value.replaceAll('#', '').trim();
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? null : Color(parsed);
}
