import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';

/// A project in a list: name, its full path, and star count.
///
/// Takes plain values, not a model, so the design system stays free of the app's
/// data types and the tile can be previewed and tested in isolation.
class ProjectTile extends StatelessWidget {
  const ProjectTile({
    required this.name,
    required this.path,
    this.description,
    this.starCount = 0,
    this.onTap,
    super.key,
  });

  final String name;

  /// The full `group/project` path, shown under the name as the identifier.
  final String path;
  final String? description;
  final int starCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDescription =
        description != null && description!.trim().isNotEmpty;

    return ListTile(
      onTap: onTap,
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            path,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
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
        ],
      ),
      trailing: starCount > 0
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_outline,
                  size: 16,
                  color: LabFoxColors.pending,
                ),
                const SizedBox(width: LabFoxSpacing.xs),
                Text('$starCount', style: theme.textTheme.labelMedium),
              ],
            )
          : null,
      isThreeLine: hasDescription,
    );
  }
}
