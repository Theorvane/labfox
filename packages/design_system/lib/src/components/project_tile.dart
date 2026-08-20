import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';

/// A project in a list, shaped like a repository card: a leading avatar, the
/// name, its path and description, and a footer of stars and visibility.
///
/// Takes plain values, not a model, so the design system stays free of the
/// app's data types and the tile can be previewed and tested in isolation.
class ProjectTile extends StatelessWidget {
  const ProjectTile({
    required this.name,
    required this.path,
    this.description,
    this.starCount = 0,
    this.avatarUrl,
    this.visibility,
    this.onTap,
    super.key,
  });

  final String name;

  /// The full `group/project` path, shown under the name as the identifier.
  final String path;
  final String? description;
  final int starCount;

  /// The project's avatar; falls back to the name initial when absent.
  final String? avatarUrl;

  /// `private`, `internal` or `public` — shown with a matching glyph.
  final String? visibility;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDescription =
        description != null && description!.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LabFoxSpacing.md,
          vertical: LabFoxSpacing.sm + 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(name: name, avatarUrl: avatarUrl),
            const SizedBox(width: LabFoxSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    path,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  if (hasDescription)
                    Padding(
                      padding: const EdgeInsets.only(top: LabFoxSpacing.xs),
                      child: Text(
                        description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  _Footer(starCount: starCount, visibility: visibility),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return Container(
      width: 36,
      height: 36,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(9),
        image: avatarUrl == null
            ? null
            : DecorationImage(
                image: NetworkImage(avatarUrl!),
                fit: BoxFit.cover,
              ),
      ),
      child: avatarUrl == null
          ? Text(
              initial,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.hintColor,
              ),
            )
          : null,
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.starCount, this.visibility});

  final int starCount;
  final String? visibility;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <Widget>[
      if (starCount > 0)
        _FooterItem(icon: Icons.star_outline, label: '$starCount'),
      if (visibility != null)
        _FooterItem(
          icon: visibility == 'private'
              ? Icons.lock_outline
              : (visibility == 'internal'
                    ? Icons.shield_outlined
                    : Icons.public),
          label: visibility!,
        ),
    ];
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: LabFoxSpacing.xs),
      child: DefaultTextStyle.merge(
        style: theme.textTheme.labelMedium!.copyWith(color: theme.hintColor),
        child: Wrap(spacing: LabFoxSpacing.md, children: items),
      ),
    );
  }
}

class _FooterItem extends StatelessWidget {
  const _FooterItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: LabFoxColors.pending),
        const SizedBox(width: LabFoxSpacing.xs),
        Text(label),
      ],
    );
  }
}
