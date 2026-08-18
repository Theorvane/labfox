import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
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
              data: (job) => Row(
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
