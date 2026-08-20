import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../core/ui/ci_visual.dart';
import '../../../core/ui/share_link_button.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/pipelines_controllers.dart';

/// One pipeline: its status header and jobs grouped by stage.
class PipelineDetailScreen extends ConsumerWidget {
  const PipelineDetailScreen({
    required this.projectId,
    required this.pipelineId,
    super.key,
  });

  final int projectId;
  final int pipelineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pipelineRef = PipelineRef(
      projectId: projectId,
      pipelineId: pipelineId,
    );
    final detail = ref.watch(pipelineDetailProvider(pipelineRef));
    final jobs = ref.watch(pipelineJobsControllerProvider(pipelineRef));

    return Scaffold(
      appBar: AppBar(
        title: Text('#$pipelineId'),
        actions: [ShareLinkButton(url: detail.valueOrNull?.webUrl)],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pipelineDetailProvider(pipelineRef));
          ref.invalidate(pipelineJobsControllerProvider(pipelineRef));
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: LabFoxSpacing.md),
          children: [
            detail.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LabFoxSpacing.md,
                ),
                child: Text(l10n.pipelineError),
              ),
              data: (p) =>
                  _PipelineHeader(pipelineRef: pipelineRef, pipeline: p),
            ),
            const Divider(height: LabFoxSpacing.xl),
            jobs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LabFoxSpacing.md,
                ),
                child: Text(l10n.pipelineJobsError),
              ),
              data: (all) {
                if (all.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: LabFoxSpacing.md,
                    ),
                    child: Text(l10n.pipelineNoJobs),
                  );
                }
                final byStage = groupJobsByStage(all);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in byStage.entries)
                      _Stage(
                        projectId: projectId,
                        stage: entry.key,
                        jobs: entry.value,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// The status header of a pipeline: a large CI glyph, the branch it ran on,
/// a status pill and identifying metadata, with the retry/cancel actions below.
class _PipelineHeader extends StatelessWidget {
  const _PipelineHeader({required this.pipelineRef, required this.pipeline});

  final PipelineRef pipelineRef;
  final Pipeline pipeline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = LabFoxStatusColors.of(context);
    final (icon, colors) = ciVisual(pipeline.ciStatus, status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LabFoxSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, size: 28, color: colors.foreground),
              ),
              const SizedBox(width: LabFoxSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pipeline.ref ?? 'Pipeline #${pipeline.id}',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: LabFoxSpacing.xs),
                    DefaultTextStyle.merge(
                      style: theme.textTheme.bodySmall!,
                      child: Wrap(
                        spacing: LabFoxSpacing.sm,
                        runSpacing: LabFoxSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          StatusPill(
                            label: ciLabel(pipeline.status),
                            colors: colors,
                            dot: true,
                          ),
                          MetaText('#${pipeline.id}'),
                          if (pipeline.shortSha != null)
                            MetaText(pipeline.shortSha!),
                          if (pipeline.createdAt != null)
                            MetaText(
                              DateFormat.yMMMd().add_jm().format(
                                pipeline.createdAt!.toLocal(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _PipelineActions(pipelineRef: pipelineRef, pipeline: pipeline),
        ],
      ),
    );
  }
}

/// One stage's jobs under a light stage header, each job a [WorkTile] with its
/// own CI glyph and status pill so a run reads the same as the pipelines list.
class _Stage extends StatelessWidget {
  const _Stage({
    required this.projectId,
    required this.stage,
    required this.jobs,
  });

  final int projectId;
  final String stage;
  final List<Job> jobs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = LabFoxStatusColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: LabFoxSpacing.md,
            right: LabFoxSpacing.md,
            top: LabFoxSpacing.md,
            bottom: LabFoxSpacing.xs,
          ),
          child: Row(
            children: [
              Text(
                stage.isEmpty ? '—' : stage,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(width: LabFoxSpacing.sm),
              Text(
                '${jobs.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
        for (final job in jobs)
          Builder(
            builder: (context) {
              final (icon, colors) = ciVisual(job.ciStatus, status);
              return WorkTile(
                icon: icon,
                iconColor: colors.foreground,
                title: job.name,
                metadata: [
                  StatusPill(
                    label: ciLabel(job.status),
                    colors: colors,
                    dot: true,
                  ),
                ],
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () => context.go(Routes.job(projectId, job.id)),
              );
            },
          ),
      ],
    );
  }
}

class _PipelineActions extends ConsumerWidget {
  const _PipelineActions({required this.pipelineRef, required this.pipeline});

  final PipelineRef pipelineRef;
  final Pipeline pipeline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final busy = ref
        .watch(pipelineActionsControllerProvider(pipelineRef))
        .isLoading;
    final notifier = ref.read(
      pipelineActionsControllerProvider(pipelineRef).notifier,
    );

    final buttons = <Widget>[
      if (pipeline.canRetry)
        OutlinedButton.icon(
          onPressed: busy ? null : () => _run(context, l10n, notifier.retry),
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(l10n.pipelineActionRetry),
        ),
      if (pipeline.canCancel)
        OutlinedButton.icon(
          onPressed: busy ? null : () => _run(context, l10n, notifier.cancel),
          icon: const Icon(Icons.stop_circle_outlined, size: 18),
          label: Text(l10n.pipelineActionCancel),
        ),
    ];
    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: LabFoxSpacing.sm),
      child: Wrap(spacing: LabFoxSpacing.sm, children: buttons),
    );
  }

  Future<void> _run(
    BuildContext context,
    AppLocalizations l10n,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on GitLabException catch (error) {
      if (context.mounted) {
        final message = switch (error) {
          GitLabForbiddenException() ||
          GitLabAuthException() => l10n.pipelineActionForbidden,
          GitLabConflictException() => l10n.pipelineActionInvalid,
          _ => l10n.pipelineActionError,
        };
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }
}
