import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/storage/local_projects_providers.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/home_work_controllers.dart';

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
            const SizedBox(height: LabFoxSpacing.lg),
            const HomeWorkFeed(),
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

/// The current user's actionable work: merge requests awaiting their review,
/// and the merge requests and issues assigned to them.
///
/// Each section is hidden when empty; when every section is empty the feed
/// shows a single all-clear line rather than nothing, so the state reads as
/// "caught up", not "broken".
class HomeWorkFeed extends ConsumerWidget {
  const HomeWorkFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final work = ref.watch(homeWorkControllerProvider);

    return work.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: LabFoxSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _WorkMessage(
        message: l10n.homeWorkError,
        onRetry: () => ref.invalidate(homeWorkControllerProvider),
      ),
      data: (data) {
        if (data.isEmpty) {
          return _WorkMessage(message: l10n.homeWorkAllClear);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.reviewRequests.isNotEmpty)
              _WorkSection(
                title: l10n.homeReviewRequests,
                icon: Icons.rate_review_outlined,
                children: [
                  for (final mr in data.reviewRequests) _mergeRequestTile(mr),
                ],
              ),
            if (data.assignedMergeRequests.isNotEmpty)
              _WorkSection(
                title: l10n.homeAssignedMergeRequests,
                icon: Icons.merge_outlined,
                children: [
                  for (final mr in data.assignedMergeRequests)
                    _mergeRequestTile(mr),
                ],
              ),
            if (data.assignedIssues.isNotEmpty)
              _WorkSection(
                title: l10n.homeAssignedIssues,
                icon: Icons.adjust,
                children: [
                  for (final issue in data.assignedIssues) _issueTile(issue),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _mergeRequestTile(MergeRequest mr) {
    return Builder(
      builder: (context) {
        final status = LabFoxStatusColors.of(context);
        final (icon, colors, label) = _mrStatus(mr, status);
        final projectId = mr.projectId;
        return WorkTile(
          icon: icon,
          iconColor: colors.foreground,
          title: mr.title,
          metadata: [
            StatusPill(label: label, colors: colors, dot: true),
            MetaText('!${mr.iid}'),
            if (mr.updatedAt != null) MetaText(timeAgo(mr.updatedAt!)),
            LabelChips(mr.labels),
          ],
          onTap: projectId == null
              ? null
              : () => context.go(Routes.mergeRequest(projectId, mr.iid)),
        );
      },
    );
  }

  Widget _issueTile(Issue issue) {
    return Builder(
      builder: (context) {
        final status = LabFoxStatusColors.of(context);
        final colors = issue.isOpen ? status.open : status.closed;
        final projectId = issue.projectId;
        return WorkTile(
          icon: issue.isOpen ? Icons.adjust : Icons.check_circle_outline,
          iconColor: colors.foreground,
          title: issue.title,
          metadata: [
            StatusPill(
              label: issue.isOpen ? 'Open' : 'Closed',
              colors: colors,
              dot: true,
            ),
            MetaText('#${issue.iid}'),
            if (issue.updatedAt != null) MetaText(timeAgo(issue.updatedAt!)),
            LabelChips(issue.labels),
          ],
          onTap: projectId == null
              ? null
              : () => context.go(Routes.issue(projectId, issue.iid)),
        );
      },
    );
  }

  static (IconData, StatusColor, String) _mrStatus(
    MergeRequest mr,
    LabFoxStatusColors s,
  ) {
    if (mr.isDraft) {
      return (Icons.merge_outlined, s.pending, 'Draft');
    }
    if (mr.isMerged) {
      return (Icons.merge, s.merged, 'Merged');
    }
    if (mr.isClosed) {
      return (Icons.close, s.closed, 'Closed');
    }
    return (Icons.merge_outlined, s.open, 'Open');
  }
}

/// A titled home section wrapping its work rows in a card, dividers between.
class _WorkSection extends StatelessWidget {
  const _WorkSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: LabFoxSpacing.md,
            bottom: LabFoxSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: theme.hintColor),
              const SizedBox(width: LabFoxSpacing.sm),
              Text(title, style: theme.textTheme.titleSmall),
            ],
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, child) in children.indexed) ...[
                if (index > 0) const Divider(height: 1),
                child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The all-clear line, or a load error with a retry.
class _WorkMessage extends StatelessWidget {
  const _WorkMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LabFoxSpacing.md),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: LabFoxSpacing.sm),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ],
      ),
    );
  }
}

/// The "My work" launcher — colour-tiled shortcuts to the account-level
/// destinations, the way GitHub Mobile opens its home, kept in LabFox tokens.
class _MyWork extends StatelessWidget {
  const _MyWork();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = LabFoxStatusColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: LabFoxSpacing.sm),
          child: Text(
            l10n.homeMyWork,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QuickTile(
                icon: Icons.folder_outlined,
                color: status.running.foreground,
                label: l10n.homeProjects,
                onTap: () => context.go(Routes.projects),
              ),
              const Divider(height: 1),
              _QuickTile(
                icon: Icons.inbox_outlined,
                color: status.merged.foreground,
                label: l10n.homeInbox,
                onTap: () => context.go(Routes.inbox),
              ),
              const Divider(height: 1),
              _QuickTile(
                icon: Icons.search,
                color: status.open.foreground,
                label: l10n.homeSearch,
                onTap: () => context.go(Routes.search),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A colour-tiled shortcut row: a filled icon square, a label, a chevron.
class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LabFoxSpacing.md,
          vertical: LabFoxSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            const SizedBox(width: LabFoxSpacing.md),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: theme.hintColor),
          ],
        ),
      ),
    );
  }
}
