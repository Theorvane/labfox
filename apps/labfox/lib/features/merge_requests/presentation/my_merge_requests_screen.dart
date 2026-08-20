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

/// The current user's merge requests across every project, filtered by scope
/// (assigned / review requests / created) and state.
class MyMergeRequestsScreen extends ConsumerStatefulWidget {
  const MyMergeRequestsScreen({super.key});

  @override
  ConsumerState<MyMergeRequestsScreen> createState() =>
      _MyMergeRequestsScreenState();
}

class _MyMergeRequestsScreenState extends ConsumerState<MyMergeRequestsScreen> {
  MyMergeRequestScope _scope = MyMergeRequestScope.assigned;
  MergeRequestState _state = MergeRequestState.opened;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = MyMergeRequestsQuery(scope: _scope, state: _state);
    final mrs = ref.watch(myMergeRequestsControllerProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mergeRequestsTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(
                left: LabFoxSpacing.md,
                right: LabFoxSpacing.md,
                bottom: LabFoxSpacing.sm,
              ),
              child: Row(
                children: [
                  FilterMenuChip<MyMergeRequestScope>(
                    selected: _scope,
                    options: const [
                      MyMergeRequestScope.assigned,
                      MyMergeRequestScope.reviewRequests,
                      MyMergeRequestScope.created,
                    ],
                    labelOf: (scope) => switch (scope) {
                      MyMergeRequestScope.assigned => l10n.scopeAssigned,
                      MyMergeRequestScope.reviewRequests =>
                        l10n.homeReviewRequests,
                      MyMergeRequestScope.created => l10n.scopeCreated,
                    },
                    onSelected: (scope) => setState(() => _scope = scope),
                  ),
                  const SizedBox(width: LabFoxSpacing.sm),
                  FilterMenuChip<MergeRequestState>(
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
                ],
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
                      ref.invalidate(myMergeRequestsControllerProvider(query)),
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
                ref.refresh(myMergeRequestsControllerProvider(query).future),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) => _tile(context, items[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _tile(BuildContext context, MergeRequest mr) {
    final l10n = AppLocalizations.of(context);
    final status = LabFoxStatusColors.of(context);
    final (icon, colors, label) = _status(mr, status);
    final blocker = mr.isOpen && !mr.isDraft
        ? mrBlocker(mr.detailedMergeStatus, l10n, status)
        : null;
    final projectId = mr.projectId;
    final path = repoPathFromWebUrl(mr.webUrl);
    return WorkTile(
      icon: icon,
      iconColor: colors.foreground,
      title: mr.title,
      metadata: [
        StatusPill(label: label, colors: colors, dot: true),
        if (blocker != null)
          StatusPill(label: blocker.label, colors: blocker.colors, dot: true),
        MetaText(path == null ? '!${mr.iid}' : '$path !${mr.iid}'),
        if (mr.updatedAt != null) MetaText(timeAgo(mr.updatedAt!)),
        LabelChips(mr.labels),
        CommentCount(mr.commentCount),
      ],
      onTap: projectId == null
          ? null
          : () => context.go(Routes.mergeRequest(projectId, mr.iid)),
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
