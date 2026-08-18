import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/merge_requests_controllers.dart';

/// One merge request: title, state, branches, labels, and the rendered
/// description. The diff, discussions, approve and merge are later slices.
class MergeRequestDetailScreen extends ConsumerWidget {
  const MergeRequestDetailScreen({
    required this.projectId,
    required this.iid,
    super.key,
  });

  final int projectId;
  final int iid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mrRef = MergeRequestRef(projectId: projectId, iid: iid);
    final mr = ref.watch(mergeRequestControllerProvider(mrRef));

    return Scaffold(
      appBar: AppBar(title: Text('!$iid')),
      body: mr.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.mergeRequestError, textAlign: TextAlign.center),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(mergeRequestControllerProvider(mrRef)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.all(LabFoxSpacing.md),
          children: [
            Text(data.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: LabFoxSpacing.sm),
            Row(
              children: [
                StateBadge(
                  state: _stateOf(data),
                  label: _stateLabel(data, l10n),
                ),
                if (data.isDraft) ...[
                  const SizedBox(width: LabFoxSpacing.sm),
                  Text(
                    l10n.mrDraft,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ],
            ),
            const SizedBox(height: LabFoxSpacing.sm),
            Text(
              '${data.sourceBranch} → ${data.targetBranch}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: LabFoxSpacing.md),
            OutlinedButton.icon(
              onPressed: () =>
                  context.go(Routes.mergeRequestChanges(projectId, iid)),
              icon: const Icon(Icons.difference_outlined, size: 18),
              label: Text(AppLocalizations.of(context).mrViewChanges),
            ),
            if (data.labels.isNotEmpty) ...[
              const SizedBox(height: LabFoxSpacing.md),
              Wrap(
                spacing: LabFoxSpacing.sm,
                runSpacing: LabFoxSpacing.sm,
                children: [
                  for (final label in data.labels)
                    GitLabLabel(name: label.name, color: label.color),
                ],
              ),
            ],
            const Divider(height: LabFoxSpacing.xl),
            if (data.description != null && data.description!.trim().isNotEmpty)
              MarkdownViewer(data: data.description!)
            else
              Text(
                l10n.mergeRequestNoDescription,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  EntityState _stateOf(MergeRequest mr) {
    if (mr.isMerged) {
      return EntityState.merged;
    }
    return mr.isOpen ? EntityState.open : EntityState.closed;
  }

  String _stateLabel(MergeRequest mr, AppLocalizations l10n) {
    if (mr.isMerged) {
      return l10n.mrStateMerged;
    }
    return mr.isOpen ? l10n.mrStateOpen : l10n.mrStateClosed;
  }
}
