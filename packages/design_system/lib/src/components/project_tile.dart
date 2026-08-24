import 'package:flutter/material.dart';

import '../tokens/icon_size.dart';
import '../tokens/icons.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

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
    this.trailing,
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

  /// An optional trailing action, e.g. a favorite toggle.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final roles = LabFoxTextRoles.of(context);
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
                    style: roles.rowTitle,
                  ),
                  Text(
                    path,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: roles.meta,
                  ),
                  if (hasDescription)
                    Padding(
                      padding: const EdgeInsets.only(top: LabFoxSpacing.xs),
                      child: Text(
                        description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: roles.body.copyWith(fontSize: 13),
                      ),
                    ),
                  _Footer(starCount: starCount, visibility: visibility),
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
        borderRadius: BorderRadius.circular(LabFoxRadius.sm),
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
                color: theme.colorScheme.onSurfaceVariant,
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
    final items = <Widget>[
      if (starCount > 0)
        _FooterItem(icon: LabFoxIcons.starBorder, label: '$starCount'),
      if (visibility != null)
        _FooterItem(
          icon: visibility == 'private'
              ? LabFoxIcons.private
              : (visibility == 'internal'
                    ? Icons.shield_outlined
                    : LabFoxIcons.public),
          label: visibility!,
        ),
    ];
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: LabFoxSpacing.xs),
      child: DefaultTextStyle.merge(
        style: LabFoxTextRoles.of(context).meta,
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
        Icon(
          icon,
          size: LabFoxIconSize.sm,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: LabFoxSpacing.xs),
        Text(label),
      ],
    );
  }
}
