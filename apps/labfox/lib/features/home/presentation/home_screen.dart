import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/storage/local_projects_providers.dart';
import '../../../l10n/app_localizations.dart';

/// Where the user's work starts.
///
/// The primary destinations (Inbox, Search, Me) live in the navigation shell;
/// this screen shows the projects entry and the favorite / recent shortcuts.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final account = ref.watch(currentAccountProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: _Body(username: account?.user.username),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({this.username});

  final String? username;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsets.all(LabFoxSpacing.lg),
          children: [
            if (username != null)
              Text(
                l10n.homeSignedInAs(username!),
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: LabFoxSpacing.lg),
            const _MyWork(),
            const _ProjectSection(favorites: true),
            const _ProjectSection(favorites: false),
          ],
        ),
      ),
    );
  }
}

/// A home section listing the favorite or recent projects, hidden when empty.
class _ProjectSection extends ConsumerWidget {
  const _ProjectSection({required this.favorites});

  final bool favorites;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final projects = favorites
        ? ref.watch(favoriteProjectsProvider)
        : ref.watch(recentProjectsProvider);
    if (projects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: LabFoxSpacing.lg),
        Padding(
          padding: const EdgeInsets.only(bottom: LabFoxSpacing.sm),
          child: Text(
            favorites ? l10n.homeFavorites : l10n.homeRecents,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, project) in projects.indexed) ...[
                if (index > 0) const Divider(height: 1),
                ProjectTile(
                  name: project.name,
                  path: project.pathWithNamespace,
                  description: project.description,
                  starCount: project.starCount,
                  onTap: () => context.go(Routes.projectOverview(project.id)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MyWork extends StatelessWidget {
  const _MyWork();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: const Icon(Icons.folder_outlined),
          title: Text(l10n.homeProjects),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go(Routes.projects),
        ),
      ),
    );
  }
}
