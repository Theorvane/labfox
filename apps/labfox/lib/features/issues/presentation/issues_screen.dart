import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/issues_controllers.dart';

/// A project's issues, with an open/closed filter.
class IssuesScreen extends ConsumerStatefulWidget {
  const IssuesScreen({required this.projectId, super.key});

  final int projectId;

  @override
  ConsumerState<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends ConsumerState<IssuesScreen> {
  IssueState _state = IssueState.opened;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = IssuesQuery(projectId: widget.projectId, state: _state);
    final issues = ref.watch(issuesControllerProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.issuesTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LabFoxSpacing.md,
              vertical: LabFoxSpacing.sm,
            ),
            child: SegmentedButton<IssueState>(
              segments: [
                ButtonSegment(
                  value: IssueState.opened,
                  label: Text(l10n.issuesFilterOpen),
                ),
                ButtonSegment(
                  value: IssueState.closed,
                  label: Text(l10n.issuesFilterClosed),
                ),
              ],
              selected: {_state},
              onSelectionChanged: (s) => setState(() => _state = s.first),
            ),
          ),
        ),
      ),
      body: issues.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.issuesError, textAlign: TextAlign.center),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(issuesControllerProvider(query)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(icon: Icons.adjust, title: l10n.issuesEmpty);
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(issuesControllerProvider(query).future),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) => _IssueTile(
                issue: items[index],
                onTap: () => context.go(
                  Routes.issue(widget.projectId, items[index].iid),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IssueTile extends StatelessWidget {
  const _IssueTile({required this.issue, required this.onTap});

  final Issue issue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = LabFoxStatusColors.of(context);
    final open = issue.isOpen;
    final colors = open ? status.open : status.closed;
    return WorkTile(
      icon: open ? Icons.adjust : Icons.check_circle_outline,
      iconColor: colors.foreground,
      title: issue.title,
      metadata: [
        StatusPill(label: open ? 'Open' : 'Closed', colors: colors, dot: true),
        MetaText('#${issue.iid}'),
        if (issue.updatedAt != null) MetaText(timeAgo(issue.updatedAt!)),
        LabelChips(issue.labels),
        CommentCount(issue.commentCount),
        if (issue.assignees.isNotEmpty) UserAvatar(user: issue.assignees.first),
      ],
      onTap: onTap,
    );
  }
}
