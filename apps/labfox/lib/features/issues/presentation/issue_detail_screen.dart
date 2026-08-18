import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';

import '../../../l10n/app_localizations.dart';
import '../../comments/presentation/widgets/comment_thread.dart';
import 'controllers/issues_controllers.dart';

/// One issue: title, state, author, labels, and the rendered description.
///
/// Read-only for this slice; comments, state changes and label editing follow.
class IssueDetailScreen extends ConsumerWidget {
  const IssueDetailScreen({
    required this.projectId,
    required this.iid,
    super.key,
  });

  final int projectId;
  final int iid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final issueRef = IssueRef(projectId: projectId, iid: iid);
    final issue = ref.watch(issueControllerProvider(issueRef));

    return Scaffold(
      appBar: AppBar(title: Text('#$iid')),
      body: issue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.issueError, textAlign: TextAlign.center),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(issueControllerProvider(issueRef)),
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
                  state: data.isOpen ? EntityState.open : EntityState.closed,
                  label: data.isOpen
                      ? l10n.issueStateOpen
                      : l10n.issueStateClosed,
                ),
                if (data.author != null) ...[
                  const SizedBox(width: LabFoxSpacing.md),
                  Flexible(
                    child: Text(
                      l10n.issueOpenedBy(data.author!.username),
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
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
                l10n.issueNoDescription,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: LabFoxSpacing.xl),
            CommentThread(
              type: NoteableType.issue,
              projectId: projectId,
              iid: iid,
            ),
          ],
        ),
      ),
    );
  }
}
