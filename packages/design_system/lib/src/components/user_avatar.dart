import 'package:flutter/material.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// A small round avatar for a GitLab user — their photo when the instance
/// serves one, otherwise the first letter of their name on a filled circle so a
/// row never shows a blank.
class UserAvatar extends StatelessWidget {
  const UserAvatar({required this.user, this.radius = 9, super.key});

  final User user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarUrl = user.avatarUrl;
    final initial = user.name.isEmpty
        ? '?'
        : user.name.characters.first.toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary,
      backgroundImage: avatarUrl == null ? null : NetworkImage(avatarUrl),
      child: avatarUrl == null
          ? Text(
              initial,
              style: TextStyle(
                fontSize: radius,
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }
}
