import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/ui/mr_blocker.dart';
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
  bool _searching = false;
  String? _search;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _closeSearch() {
    _searchController.clear();
    setState(() {
      _searching = false;
      _search = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = MergeRequestsQuery(
      projectId: widget.projectId,
      state: _state,
      search: _search,
    );
    final mrs = ref.watch(mergeRequestsControllerProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.listSearchHint,
                  border: InputBorder.none,
                ),
                onSubmitted: (term) =>
                    setState(() => _search = term.trim().isEmpty ? null : term),
              )
            : Text(l10n.mergeRequestsTitle),
        actions: [
          if (_searching)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.listSearchClose,
              onPressed: _closeSearch,
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: l10n.searchTitle,
              onPressed: () => setState(() => _searching = true),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: l10n.newMrButton,
              onPressed: () =>
                  context.go(Routes.newMergeRequest(widget.projectId)),
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                left: LabFoxSpacing.md,
                right: LabFoxSpacing.md,
                bottom: LabFoxSpacing.sm,
              ),
              child: FilterMenuChip<MergeRequestState>(
                selected: _state,
                options: const [
                  MergeRequestState.opened,
                  MergeRequestState.merged,
                  MergeRequestState.closed,
                ],
                labelOf: (state) => switch (state) {
                  MergeRequestState.opened => l10n.mrFilterOpen,
                  MergeRequestState.merged => l10n.mrFilterMerged,
                  _ => l10n.mrFilterClosed,
                },
                onSelected: (state) => setState(() => _state = state),
              ),
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
            return EmptyState(
              icon: Icons.merge_outlined,
              title: l10n.mergeRequestsEmpty,
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(mergeRequestsControllerProvider(query).future),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) => _MergeRequestTile(
                mr: items[index],
                onTap: () => context.go(
                  Routes.mergeRequest(widget.projectId, items[index].iid),
                ),
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
    final l10n = AppLocalizations.of(context);
    final status = LabFoxStatusColors.of(context);
    final (icon, colors, label) = _status(mr, status);
    final blocker = mr.isOpen && !mr.isDraft
        ? mrBlocker(mr.detailedMergeStatus, l10n, status)
        : null;
    return WorkTile(
      icon: icon,
      iconColor: colors.foreground,
      title: mr.title,
      metadata: [
        StatusPill(label: label, colors: colors, dot: true),
        if (blocker != null)
          StatusPill(label: blocker.label, colors: blocker.colors, dot: true),
        MetaText('!${mr.iid}'),
        if (mr.updatedAt != null) MetaText(timeAgo(mr.updatedAt!)),
        if (mr.author != null) MetaText(mr.author!.username),
        LabelChips(mr.labels),
        CommentCount(mr.commentCount),
        if (mr.assignees.isNotEmpty) UserAvatar(user: mr.assignees.first),
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
