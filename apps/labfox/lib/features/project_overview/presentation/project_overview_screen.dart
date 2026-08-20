import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/storage/local_projects_providers.dart';
import '../../../core/ui/share_link_button.dart';
import '../../../l10n/app_localizations.dart';
import '../data/project_overview.dart';
import 'controllers/project_overview_controller.dart';

/// A project's overview: identity, README, and links into its sections.
class ProjectOverviewScreen extends ConsumerStatefulWidget {
  const ProjectOverviewScreen({required this.projectId, super.key});

  final int projectId;

  @override
  ConsumerState<ProjectOverviewScreen> createState() =>
      _ProjectOverviewScreenState();
}

class _ProjectOverviewScreenState extends ConsumerState<ProjectOverviewScreen> {
  @override
  void initState() {
    super.initState();
    // Record the project as recently opened once it has loaded. Fires
    // immediately so an already-cached project still counts, and recording is
    // idempotent (it just moves the project to the front).
    ref.listenManual(projectOverviewControllerProvider(widget.projectId), (
      _,
      next,
    ) {
      final project = next.valueOrNull?.project;
      if (project != null) {
        ref.read(recentProjectsProvider.notifier).record(project);
      }
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    final projectId = widget.projectId;
    final l10n = AppLocalizations.of(context);
    final overview = ref.watch(projectOverviewControllerProvider(projectId));

    final project = overview.valueOrNull?.project;
    final isFavorite = ref.watch(
      favoriteProjectsProvider.select(
        (favorites) => favorites.any((p) => p.id == projectId),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(project?.name ?? l10n.projectOverviewTitle),
        actions: [
          if (project != null)
            IconButton(
              icon: Icon(isFavorite ? Icons.star : Icons.star_border),
              tooltip: isFavorite
                  ? l10n.projectRemoveFavorite
                  : l10n.projectAddFavorite,
              onPressed: () =>
                  ref.read(favoriteProjectsProvider.notifier).toggle(project),
            ),
          ShareLinkButton(url: project?.webUrl),
        ],
      ),
      body: overview.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _Error(
          message: l10n.projectOverviewError,
          onRetry: () => ref
              .read(projectOverviewControllerProvider(projectId).notifier)
              .refresh(),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref
              .read(projectOverviewControllerProvider(projectId).notifier)
              .refresh(),
          child: ListView(
            padding: const EdgeInsets.all(LabFoxSpacing.md),
            children: [
              _Header(project: data.project),
              const SizedBox(height: LabFoxSpacing.md),
              _Categories(project: data.project),
              const SizedBox(height: LabFoxSpacing.lg),
              _Readme(overview: data),
            ],
          ),
        ),
      ),
    );
  }
}

/// The project's sections as one card of colour-tiled shortcuts — the launcher
/// pattern GitHub Mobile uses for a repository, kept in LabFox's own tokens.
class _Categories extends StatelessWidget {
  const _Categories({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = LabFoxStatusColors.of(context);
    final branch = project.defaultBranch;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CategoryTile(
            icon: Icons.error_outline,
            color: status.open.foreground,
            label: l10n.projectOverviewIssues,
            onTap: () => context.go(Routes.issues(project.id)),
          ),
          const Divider(height: 1),
          _CategoryTile(
            icon: Icons.merge_outlined,
            color: status.merged.foreground,
            label: l10n.projectOverviewMergeRequests,
            onTap: () => context.go(Routes.mergeRequests(project.id)),
          ),
          const Divider(height: 1),
          _CategoryTile(
            icon: Icons.rocket_launch_outlined,
            color: status.running.foreground,
            label: l10n.projectOverviewPipelines,
            onTap: () => context.go(Routes.pipelines(project.id)),
          ),
          if (branch != null) ...[
            const Divider(height: 1),
            _CategoryTile(
              icon: Icons.folder_copy_outlined,
              color: status.pending.foreground,
              label: l10n.projectOverviewRepository,
              onTap: () => context.go(Routes.repository(project.id, branch)),
            ),
            const Divider(height: 1),
            _CategoryTile(
              icon: Icons.account_tree_outlined,
              color: status.pending.foreground,
              label: l10n.projectOverviewBranches,
              onTap: () => context.go(Routes.branches(project.id)),
            ),
            const Divider(height: 1),
            _CategoryTile(
              icon: Icons.history,
              color: status.pending.foreground,
              label: l10n.projectOverviewCommits,
              onTap: () => context.go(Routes.commits(project.id, branch)),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
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

class _Header extends StatelessWidget {
  const _Header({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(project.name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: LabFoxSpacing.xs),
        Text(project.pathWithNamespace, style: theme.textTheme.bodySmall),
        const SizedBox(height: LabFoxSpacing.sm),
        Row(
          children: [
            if (project.visibility != null) ...[
              Icon(
                project.visibility == 'private'
                    ? Icons.lock_outline
                    : Icons.public,
                size: 16,
                color: LabFoxColors.pending,
              ),
              const SizedBox(width: LabFoxSpacing.xs),
              Text(project.visibility!, style: theme.textTheme.labelMedium),
              const SizedBox(width: LabFoxSpacing.md),
            ],
            const Icon(
              Icons.star_outline,
              size: 16,
              color: LabFoxColors.pending,
            ),
            const SizedBox(width: LabFoxSpacing.xs),
            Text('${project.starCount}', style: theme.textTheme.labelMedium),
          ],
        ),
      ],
    );
  }
}

class _Readme extends StatelessWidget {
  const _Readme({required this.overview});

  final ProjectOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final readme = overview.readme;
    if (readme == null || readme.trim().isEmpty) {
      return Text(
        l10n.projectOverviewNoReadme,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    return MarkdownViewer(data: readme);
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: LabFoxSpacing.md),
            FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
