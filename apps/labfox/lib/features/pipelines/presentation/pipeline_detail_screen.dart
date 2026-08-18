import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
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
      appBar: AppBar(title: Text('#$pipelineId')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pipelineDetailProvider(pipelineRef));
          ref.invalidate(pipelineJobsControllerProvider(pipelineRef));
        },
        child: ListView(
          padding: const EdgeInsets.all(LabFoxSpacing.md),
          children: [
            detail.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text(l10n.pipelineError),
              data: (p) => Row(
                children: [
                  CiStatusIcon(status: p.ciStatus, label: p.status),
                  const SizedBox(width: LabFoxSpacing.md),
                  if (p.ref != null)
                    Text(p.ref!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Divider(height: LabFoxSpacing.xl),
            jobs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text(l10n.pipelineJobsError),
              data: (all) {
                if (all.isEmpty) {
                  return Text(l10n.pipelineNoJobs);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: LabFoxSpacing.md,
            bottom: LabFoxSpacing.xs,
          ),
          child: Text(
            stage.isEmpty ? '—' : stage,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        for (final job in jobs)
          InkWell(
            onTap: () => context.go(Routes.job(projectId, job.id)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: LabFoxSpacing.sm),
              child: Row(
                children: [
                  CiStatusIcon(status: job.ciStatus),
                  const SizedBox(width: LabFoxSpacing.sm),
                  Expanded(
                    child: Text(job.name, overflow: TextOverflow.ellipsis),
                  ),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
