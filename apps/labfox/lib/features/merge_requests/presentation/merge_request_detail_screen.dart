import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/ui/copy_link_button.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import '../../comments/presentation/widgets/comment_thread.dart';
import 'controllers/merge_requests_controllers.dart';
import 'widgets/mr_actions.dart';

/// One merge request: an identity header, the description and discussion, with
/// the approve / merge actions pinned to a sticky bar so they never scroll away.
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
    final open = mr.valueOrNull?.isOpen ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('!$iid'),
        actions: [CopyLinkButton(url: mr.valueOrNull?.webUrl)],
      ),
      bottomNavigationBar: open
          ? _ActionBar(mr: mr.value!, projectId: projectId)
          : null,
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
            _Header(mr: data),
            const SizedBox(height: LabFoxSpacing.md),
            _BranchChip(source: data.sourceBranch, target: data.targetBranch),
            const SizedBox(height: LabFoxSpacing.md),
            OutlinedButton.icon(
              onPressed: () =>
                  context.go(Routes.mergeRequestChanges(projectId, iid)),
              icon: const Icon(Icons.difference_outlined, size: 18),
              label: Text(l10n.mrViewChanges),
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
            const SizedBox(height: LabFoxSpacing.xl),
            CommentThread(
              type: NoteableType.mergeRequest,
              projectId: projectId,
              iid: iid,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.mr});

  final MergeRequest mr;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final status = LabFoxStatusColors.of(context);
    final (colors, label) = _status(mr, status, l10n);

    final path = repoPathFromWebUrl(mr.webUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MetaText(path == null ? '!${mr.iid}' : '$path !${mr.iid}'),
        const SizedBox(height: LabFoxSpacing.xs),
        Text(
          mr.title,
          style: theme.textTheme.titleLarge?.copyWith(height: 1.2),
        ),
        const SizedBox(height: LabFoxSpacing.sm),
        Wrap(
          spacing: LabFoxSpacing.sm,
          runSpacing: LabFoxSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatusPill(label: label, colors: colors, dot: true),
            if (mr.author != null) ...[
              _Avatar(user: mr.author!),
              MetaText(mr.author!.username),
            ],
          ],
        ),
      ],
    );
  }

  static (StatusColor, String) _status(
    MergeRequest mr,
    LabFoxStatusColors s,
    AppLocalizations l10n,
  ) {
    if (mr.isDraft) {
      return (s.pending, l10n.mrDraft);
    }
    if (mr.isMerged) {
      return (s.merged, l10n.mrStateMerged);
    }
    if (mr.isClosed) {
      return (s.closed, l10n.mrStateClosed);
    }
    return (s.open, l10n.mrStateOpen);
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final url = user.avatarUrl;
    return CircleAvatar(
      radius: 9,
      backgroundColor: LabFoxStatusColors.of(context).merged.foreground,
      backgroundImage: url == null ? null : NetworkImage(url),
      child: url == null
          ? Text(
              user.name.characters.first.toUpperCase(),
              style: const TextStyle(fontSize: 9, color: Colors.white),
            )
          : null,
    );
  }
}

class _BranchChip extends StatelessWidget {
  const _BranchChip({required this.source, required this.target});

  final String source;
  final String target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mono = theme.textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LabFoxSpacing.md,
        vertical: LabFoxSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(source, style: mono, overflow: TextOverflow.ellipsis),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: LabFoxSpacing.sm),
            child: Icon(
              Icons.arrow_forward,
              size: 14,
              color: theme.colorScheme.primary,
            ),
          ),
          Flexible(
            child: Text(target, style: mono, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

/// The approve / merge controls, pinned above the safe area with a divider.
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.mr, required this.projectId});

  final MergeRequest mr;
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            LabFoxSpacing.md,
            LabFoxSpacing.sm,
            LabFoxSpacing.md,
            LabFoxSpacing.sm,
          ),
          child: MrActions(mr: mr, projectId: projectId),
        ),
      ),
    );
  }
}
