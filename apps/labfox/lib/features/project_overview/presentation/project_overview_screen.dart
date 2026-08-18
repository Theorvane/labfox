import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../data/project_overview.dart';
import 'controllers/project_overview_controller.dart';

/// A project's overview: identity, README, and links into its sections.
class ProjectOverviewScreen extends ConsumerWidget {
  const ProjectOverviewScreen({required this.projectId, super.key});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final overview = ref.watch(projectOverviewControllerProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          overview.valueOrNull?.project.name ?? l10n.projectOverviewTitle,
        ),
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
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: Text(
                    AppLocalizations.of(context).projectOverviewIssues,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(Routes.issues(data.project.id)),
                ),
              ),
              const SizedBox(height: LabFoxSpacing.md),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.merge_outlined),
                  title: Text(
                    AppLocalizations.of(context).projectOverviewMergeRequests,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.go(Routes.mergeRequests(data.project.id)),
                ),
              ),
              const SizedBox(height: LabFoxSpacing.md),
              if (data.project.defaultBranch != null)
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.folder_copy_outlined),
                        title: Text(
                          AppLocalizations.of(
                            context,
                          ).projectOverviewRepository,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go(
                          Routes.repository(
                            data.project.id,
                            data.project.defaultBranch!,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.account_tree_outlined),
                        title: Text(
                          AppLocalizations.of(context).projectOverviewBranches,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            context.go(Routes.branches(data.project.id)),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(
                          AppLocalizations.of(context).projectOverviewCommits,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go(
                          Routes.commits(
                            data.project.id,
                            data.project.defaultBranch!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: LabFoxSpacing.lg),
              _Readme(overview: data),
            ],
          ),
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
