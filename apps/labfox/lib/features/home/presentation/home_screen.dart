import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/responsive.dart';
import '../../../app/router.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/storage/local_projects_providers.dart';
import '../../../l10n/app_localizations.dart';

/// Where the user's work starts.
///
/// For this slice it confirms who is signed in and offers sign-out. Issues,
/// merge requests and pipelines land in later M1 and M2 pull requests.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final account = ref.watch(currentAccountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: l10n.homeSwitchAccount,
            onPressed: () => context.go(Routes.accounts),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.go(Routes.settings),
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: (context) => _Body(username: account?.user.username),
        desktop: (context) => Row(
          children: [
            const SizedBox(width: 260, child: _NavigationPlaceholder()),
            const VerticalDivider(width: 1),
            Expanded(child: _Body(username: account?.user.username)),
          ],
        ),
      ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.inbox_outlined),
              title: Text(l10n.homeInbox),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(Routes.inbox),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.search),
              title: Text(l10n.homeSearch),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(Routes.search),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(l10n.homeProjects),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(Routes.projects),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationPlaceholder extends StatelessWidget {
  const _NavigationPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(LabFoxSpacing.md),
      child: Align(alignment: Alignment.topLeft, child: Text('Navigation')),
    );
  }
}
