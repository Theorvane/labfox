import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// The `group/project` path from a GitLab `web_url`, or null when it cannot be
/// read — used as the eyebrow above a merge request or issue title.
///
/// A GitLab web URL looks like `https://host/group/sub/project/-/issues/282`;
/// the project path is everything before the `/-/` marker.
String? repoPathFromWebUrl(String? webUrl) {
  if (webUrl == null) {
    return null;
  }
  final uri = Uri.tryParse(webUrl);
  if (uri == null) {
    return null;
  }
  final marker = uri.path.indexOf('/-/');
  final path = marker >= 0 ? uri.path.substring(0, marker) : uri.path;
  final trimmed = path.replaceAll(RegExp(r'^/+|/+$'), '');
  return trimmed.isEmpty ? null : trimmed;
}

/// A short relative time like `now`, `5m`, `3h`, `7d`, `2w`, `4mo`, `1y`.
///
/// [now] is injectable so the format is testable without a real clock. A time
/// in the future clamps to `now` rather than showing a negative age.
String timeAgo(DateTime time, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final diff = current.difference(time);
  if (diff.inSeconds < 60) {
    return 'now';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}h';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}d';
  }
  if (diff.inDays < 30) {
    return '${diff.inDays ~/ 7}w';
  }
  if (diff.inDays < 365) {
    return '${diff.inDays ~/ 30}mo';
  }
  return '${diff.inDays ~/ 365}y';
}

/// Muted, tabular metadata text for a work row — an IID, an author, a date.
class MetaText extends StatelessWidget {
  const MetaText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: LabFoxTextRoles.of(
        context,
      ).meta.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
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
    final roles = LabFoxTextRoles.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          LabFoxIcons.comment,
          size: LabFoxIconSize.xs,
          color: roles.meta.color,
        ),
        const SizedBox(width: 3),
        Text('$count', style: roles.meta),
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
        borderRadius: BorderRadius.circular(LabFoxRadius.pill),
      ),
      child: Text(
        label.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: LabFoxTextRoles.of(
          context,
        ).chipLabel.copyWith(color: foreground),
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
