import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/pipelines_controllers.dart';

/// A project's pipelines, most recent first.
class PipelinesScreen extends ConsumerWidget {
  const PipelinesScreen({required this.projectId, super.key});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pipelines = ref.watch(pipelinesControllerProvider(projectId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pipelinesTitle)),
      body: pipelines.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.pipelinesError, textAlign: TextAlign.center),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(pipelinesControllerProvider(projectId)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.pipelinesEmpty));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => _PipelineTile(
              pipeline: items[index],
              onTap: () =>
                  context.go(Routes.pipeline(projectId, items[index].id)),
            ),
          );
        },
      ),
    );
  }
}

class _PipelineTile extends StatelessWidget {
  const _PipelineTile({required this.pipeline, required this.onTap});

  final Pipeline pipeline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [
      '#${pipeline.id}',
      if (pipeline.ref != null) pipeline.ref!,
      if (pipeline.createdAt != null)
        DateFormat.yMMMd().format(pipeline.createdAt!.toLocal()),
    ].join(' · ');

    return ListTile(
      leading: CiStatusIcon(status: pipeline.ciStatus),
      title: Text(pipeline.status, style: theme.textTheme.titleSmall),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
