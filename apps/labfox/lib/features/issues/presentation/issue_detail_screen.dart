import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../core/ui/share_link_button.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import '../../comments/presentation/widgets/comment_thread.dart';
import 'controllers/issues_controllers.dart';

/// One issue: title, state, author, labels, the rendered description, and its
/// comment thread. The overflow menu closes or reopens the issue.
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
      appBar: AppBar(
        title: Text('#$iid'),
        actions: [
          ShareLinkButton(url: issue.valueOrNull?.webUrl),
          if (issue.valueOrNull case final data?)
            PopupMenuButton<bool>(
              onSelected: (open) => _setOpen(context, ref, issueRef, open),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: !data.isOpen,
                  child: Text(data.isOpen ? l10n.issueClose : l10n.issueReopen),
                ),
              ],
            ),
        ],
      ),
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
            _IssueHeader(issue: data),
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

  Future<void> _setOpen(
    BuildContext context,
    WidgetRef ref,
    IssueRef issueRef,
    bool open,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(issueControllerProvider(issueRef).notifier).setOpen(open);
    } on GitLabException {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.issueStateError)));
      }
    }
  }
}

class _IssueHeader extends StatelessWidget {
  const _IssueHeader({required this.issue});

  final Issue issue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final status = LabFoxStatusColors.of(context);
    final open = issue.isOpen;
    final colors = open ? status.open : status.closed;

    final path = repoPathFromWebUrl(issue.webUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MetaText(path == null ? '#${issue.iid}' : '$path #${issue.iid}'),
        const SizedBox(height: LabFoxSpacing.xs),
        Text(
          issue.title,
          style: theme.textTheme.titleLarge?.copyWith(height: 1.2),
        ),
        const SizedBox(height: LabFoxSpacing.sm),
        Wrap(
          spacing: LabFoxSpacing.sm,
          runSpacing: LabFoxSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatusPill(
              label: open ? l10n.issueStateOpen : l10n.issueStateClosed,
              colors: colors,
              icon: open ? Icons.adjust : Icons.check_circle_outline,
              filled: true,
            ),
            if (issue.author != null) ...[
              CircleAvatar(
                radius: 9,
                backgroundColor: status.merged.foreground,
                backgroundImage: issue.author!.avatarUrl == null
                    ? null
                    : NetworkImage(issue.author!.avatarUrl!),
                child: issue.author!.avatarUrl == null
                    ? Text(
                        issue.author!.name.characters.first.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              MetaText(issue.author!.username),
            ],
          ],
        ),
      ],
    );
  }
}
