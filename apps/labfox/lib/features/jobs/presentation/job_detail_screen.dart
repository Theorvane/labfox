import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../l10n/app_localizations.dart';
import 'controllers/job_actions_controller.dart';
import 'controllers/job_controllers.dart';

/// One job: its status header and its log with ANSI colours.
class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({
    required this.projectId,
    required this.jobId,
    super.key,
  });

  final int projectId;
  final int jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final jobRef = JobRef(projectId: projectId, jobId: jobId);
    final detail = ref.watch(jobDetailProvider(jobRef));
    final trace = ref.watch(jobTraceProvider(jobRef));

    return Scaffold(
      appBar: AppBar(
        title: Text(detail.valueOrNull?.name ?? l10n.jobTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.jobRefresh,
            onPressed: () {
              ref.invalidate(jobDetailProvider(jobRef));
              ref.invalidate(jobTraceProvider(jobRef));
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.md),
            child: detail.when(
              loading: () => const SizedBox(
                height: 20,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text(l10n.jobError),
              data: (job) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CiStatusIcon(status: job.ciStatus, label: job.status),
                      if (job.stage != null) ...[
                        const SizedBox(width: LabFoxSpacing.md),
                        Text(
                          job.stage!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                  _JobActionBar(projectId: projectId, jobId: jobId, job: job),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: trace.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(l10n.jobLogError)),
              data: (text) {
                if (text.trim().isEmpty) {
                  return Center(child: Text(l10n.jobLogEmpty));
                }
                return SingleChildScrollView(child: AnsiLogView(trace: text));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _JobActionBar extends ConsumerWidget {
  const _JobActionBar({
    required this.projectId,
    required this.jobId,
    required this.job,
  });

  final int projectId;
  final int jobId;
  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final jobRef = JobRef(projectId: projectId, jobId: jobId);
    final busy = ref.watch(jobActionsControllerProvider(jobRef)).isLoading;
    final notifier = ref.read(jobActionsControllerProvider(jobRef).notifier);

    final buttons = <Widget>[
      if (job.canRetry)
        _ActionButton(
          icon: Icons.refresh,
          label: l10n.jobActionRetry,
          busy: busy,
          run: notifier.retry,
        ),
      if (job.canCancel)
        _ActionButton(
          icon: Icons.stop_circle_outlined,
          label: l10n.jobActionCancel,
          busy: busy,
          run: notifier.cancel,
        ),
      if (job.canPlay)
        _ActionButton(
          icon: Icons.play_arrow,
          label: l10n.jobActionRun,
          busy: busy,
          run: notifier.play,
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
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.busy,
    required this.run,
  });

  final IconData icon;
  final String label;
  final bool busy;
  final Future<void> Function() run;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OutlinedButton.icon(
      onPressed: busy ? null : () => _run(context, l10n),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Future<void> _run(BuildContext context, AppLocalizations l10n) async {
    try {
      await run();
    } on GitLabException catch (error) {
      if (context.mounted) {
        final message = switch (error) {
          GitLabForbiddenException() ||
          GitLabAuthException() => l10n.jobActionForbidden,
          GitLabConflictException() => l10n.jobActionInvalid,
          _ => l10n.jobActionError,
        };
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }
}
