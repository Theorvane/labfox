import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/merge_requests_controllers.dart';

/// A project's merge requests, filtered by state.
class MergeRequestsScreen extends ConsumerStatefulWidget {
  const MergeRequestsScreen({required this.projectId, super.key});

  final int projectId;

  @override
  ConsumerState<MergeRequestsScreen> createState() =>
      _MergeRequestsScreenState();
}

class _MergeRequestsScreenState extends ConsumerState<MergeRequestsScreen> {
  MergeRequestState _state = MergeRequestState.opened;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = MergeRequestsQuery(
      projectId: widget.projectId,
      state: _state,
    );
    final mrs = ref.watch(mergeRequestsControllerProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mergeRequestsTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LabFoxSpacing.md,
              vertical: LabFoxSpacing.sm,
            ),
            child: SegmentedButton<MergeRequestState>(
              segments: [
                ButtonSegment(
                  value: MergeRequestState.opened,
                  label: Text(l10n.mrFilterOpen),
                ),
                ButtonSegment(
                  value: MergeRequestState.merged,
                  label: Text(l10n.mrFilterMerged),
                ),
                ButtonSegment(
                  value: MergeRequestState.closed,
                  label: Text(l10n.mrFilterClosed),
                ),
              ],
              selected: {_state},
              onSelectionChanged: (s) => setState(() => _state = s.first),
            ),
          ),
        ),
      ),
      body: mrs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.mergeRequestsError, textAlign: TextAlign.center),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(mergeRequestsControllerProvider(query)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.mergeRequestsEmpty));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => _MergeRequestTile(
              mr: items[index],
              onTap: () => context.go(
                Routes.mergeRequest(widget.projectId, items[index].iid),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MergeRequestTile extends StatelessWidget {
  const _MergeRequestTile({required this.mr, required this.onTap});

  final MergeRequest mr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = LabFoxStatusColors.of(context);
    final (icon, colors, label) = _status(mr, status);
    return WorkTile(
      icon: icon,
      iconColor: colors.foreground,
      title: mr.title,
      metadata: [
        StatusPill(label: label, colors: colors, dot: true),
        MetaText('!${mr.iid}'),
        if (mr.author != null) MetaText(mr.author!.username),
        LabelChips(mr.labels),
        CommentCount(mr.commentCount),
      ],
      onTap: onTap,
    );
  }

  static (IconData, StatusColor, String) _status(
    MergeRequest mr,
    LabFoxStatusColors s,
  ) {
    if (mr.isDraft) {
      return (Icons.merge_outlined, s.pending, 'Draft');
    }
    if (mr.isMerged) {
      return (Icons.merge, s.merged, 'Merged');
    }
    if (mr.isClosed) {
      return (Icons.close, s.closed, 'Closed');
    }
    return (Icons.merge_outlined, s.open, 'Open');
  }
}
