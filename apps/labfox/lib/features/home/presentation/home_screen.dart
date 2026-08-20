import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/storage/local_projects_providers.dart';
import '../../../l10n/app_localizations.dart';

/// Where the user's work starts: the "My work" launcher into the account-level
/// lists, then the favorite and recent projects.
///
/// Home is a launcher, not a feed — the actionable lists (my issues, my merge
/// requests, the to-do inbox) are one tap away and own their filters, the way
/// GitHub Mobile structures its home.
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
            icon: const Icon(LabFoxIcons.search),
            tooltip: l10n.searchTitle,
            onPressed: () => context.go(Routes.search),
          ),
          if (account != null)
            Padding(
              padding: const EdgeInsets.only(right: LabFoxSpacing.md),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.go(Routes.me),
                child: UserAvatar(user: account.user, radius: 14),
              ),
            ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: LabFoxSpacing.md),
            children: const [
              _MyWork(),
              _ProjectSection(favorites: true),
              _ProjectSection(favorites: false),
            ],
          ),
        ),
      ),
    );
  }
}

/// The "My work" launcher — flat rows of colour-tiled shortcuts into the
/// account-level destinations.
class _MyWork extends ConsumerWidget {
  const _MyWork();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = LabFoxStatusColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: LabFoxSpacing.md),
          child: Text(
            l10n.homeMyWork,
            style: LabFoxTextRoles.of(context).sectionHeader,
          ),
        ),
        const SizedBox(height: LabFoxSpacing.xs),
        LauncherTile(
          icon: LabFoxIcons.issueOpen,
          color: status.open.foreground,
          label: l10n.issuesTitle,
          onTap: () => context.go(Routes.myIssues),
        ),
        LauncherTile(
          icon: LabFoxIcons.mergeRequest,
          color: status.merged.foreground,
          label: l10n.mergeRequestsTitle,
          onTap: () => context.go(Routes.myMergeRequests),
        ),
        LauncherTile(
          icon: LabFoxIcons.project,
          color: status.running.foreground,
          label: l10n.homeProjects,
          onTap: () => context.go(Routes.projects),
        ),
        LauncherTile(
          icon: LabFoxIcons.inbox,
          color: status.warning.foreground,
          label: l10n.homeInbox,
          onTap: () => context.go(Routes.inbox),
        ),
      ],
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LabFoxSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: LabFoxSpacing.lg),
          Padding(
            padding: const EdgeInsets.only(bottom: LabFoxSpacing.sm),
            child: Text(
              favorites ? l10n.homeFavorites : l10n.homeRecents,
              style: LabFoxTextRoles.of(context).sectionHeader,
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
                    avatarUrl: project.avatarUrl,
                    visibility: project.visibility,
                    onTap: () => context.go(Routes.projectOverview(project.id)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
