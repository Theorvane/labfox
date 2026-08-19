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

/// A short run of label colour dots, capped at [max]. A quiet stand-in for full
/// label chips in a dense row; the detail screen shows the named labels.
class LabelDots extends StatelessWidget {
  const LabelDots(this.labels, {this.max = 3, super.key});

  final List<Label> labels;
  final int max;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }
    final fallback = Theme.of(context).hintColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final label in labels.take(max))
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: _hex(label.color) ?? fallback,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  static Color? _hex(String? value) {
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
}
