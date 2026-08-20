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
              icon: Icon(
                isFavorite ? LabFoxIcons.star : LabFoxIcons.starBorder,
              ),
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
            padding: const EdgeInsets.symmetric(vertical: LabFoxSpacing.md),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LabFoxSpacing.md,
                ),
                child: _Header(project: data.project),
              ),
              const SizedBox(height: LabFoxSpacing.md),
              _Categories(project: data.project),
              _CodeSection(project: data.project),
              const SizedBox(height: LabFoxSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LabFoxSpacing.md,
                ),
                child: _Readme(overview: data),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The project's sections as flat colour-tiled launcher rows — the repository
/// shape GitHub Mobile uses, kept in LabFox's own tokens. The open-issue count
/// rides on the Issues row when the payload carries it.
class _Categories extends StatelessWidget {
  const _Categories({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = LabFoxStatusColors.of(context);
    final branch = project.defaultBranch;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LauncherTile(
          icon: Icons.error_outline,
          color: status.open.foreground,
          label: l10n.projectOverviewIssues,
          count: project.openIssuesCount,
          onTap: () => context.go(Routes.issues(project.id)),
        ),
        LauncherTile(
          icon: LabFoxIcons.mergeRequest,
          color: status.merged.foreground,
          label: l10n.projectOverviewMergeRequests,
          onTap: () => context.go(Routes.mergeRequests(project.id)),
        ),
        LauncherTile(
          icon: LabFoxIcons.pipeline,
          color: status.running.foreground,
          label: l10n.projectOverviewPipelines,
          onTap: () => context.go(Routes.pipelines(project.id)),
        ),
        if (branch != null)
          LauncherTile(
            icon: LabFoxIcons.history,
            color: status.pending.foreground,
            label: l10n.projectOverviewCommits,
            onTap: () => context.go(Routes.commits(project.id, branch)),
          ),
      ],
    );
  }
}

/// The code section: the current (default) branch, opening the branch list,
/// and a browse entry into the file tree — GitHub Mobile's code block. Hidden
/// entirely for an empty repository, which has no branch to browse.
class _CodeSection extends StatelessWidget {
  const _CodeSection({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = LabFoxStatusColors.of(context);
    final branch = project.defaultBranch;
    if (branch == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: LabFoxSpacing.md,
            right: LabFoxSpacing.md,
            top: LabFoxSpacing.md,
          ),
          child: Text(
            l10n.projectOverviewCode,
            style: LabFoxTextRoles.of(context).sectionHeader,
          ),
        ),
        const SizedBox(height: LabFoxSpacing.xs),
        LauncherTile(
          icon: LabFoxIcons.branch,
          color: status.pending.foreground,
          label: branch,
          onTap: () => context.go(Routes.branches(project.id)),
        ),
        LauncherTile(
          icon: LabFoxIcons.code,
          color: status.pending.foreground,
          label: l10n.projectOverviewBrowseCode,
          onTap: () => context.go(Routes.repository(project.id, branch)),
        ),
      ],
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
                    ? LabFoxIcons.private
                    : LabFoxIcons.public,
                size: LabFoxIconSize.sm,
                color: LabFoxColors.pending,
              ),
              const SizedBox(width: LabFoxSpacing.xs),
              Text(project.visibility!, style: theme.textTheme.labelMedium),
              const SizedBox(width: LabFoxSpacing.md),
            ],
            const Icon(
              LabFoxIcons.starBorder,
              size: LabFoxIconSize.sm,
              color: LabFoxColors.pending,
            ),
            const SizedBox(width: LabFoxSpacing.xs),
            Text('${project.starCount}', style: theme.textTheme.labelMedium),
            if (project.forksCount != null) ...[
              const SizedBox(width: LabFoxSpacing.md),
              const Icon(
                LabFoxIcons.fork,
                size: LabFoxIconSize.sm,
                color: LabFoxColors.pending,
              ),
              const SizedBox(width: LabFoxSpacing.xs),
              Text('${project.forksCount}', style: theme.textTheme.labelMedium),
            ],
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
