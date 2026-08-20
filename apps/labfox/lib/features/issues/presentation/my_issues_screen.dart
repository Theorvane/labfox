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

/// The current user's issues across every project, filtered by scope
/// (assigned / created) and state — the account-level list Home's "My work"
/// launcher opens.
class MyIssuesScreen extends ConsumerStatefulWidget {
  const MyIssuesScreen({super.key});

  @override
  ConsumerState<MyIssuesScreen> createState() => _MyIssuesScreenState();
}

class _MyIssuesScreenState extends ConsumerState<MyIssuesScreen> {
  IssueScope _scope = IssueScope.assignedToMe;
  IssueState _state = IssueState.opened;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = MyIssuesQuery(scope: _scope, state: _state);
    final issues = ref.watch(myIssuesControllerProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.issuesTitle),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilterMenuChip<IssueScope>(
                    selected: _scope,
                    options: const [
                      IssueScope.assignedToMe,
                      IssueScope.createdByMe,
                    ],
                    labelOf: (scope) => scope == IssueScope.assignedToMe
                        ? l10n.scopeAssigned
                        : l10n.scopeCreated,
                    onSelected: (scope) => setState(() => _scope = scope),
                  ),
                  const SizedBox(width: LabFoxSpacing.sm),
                  FilterMenuChip<IssueState>(
                    selected: _state,
                    options: const [IssueState.opened, IssueState.closed],
                    labelOf: (state) => state == IssueState.opened
                        ? l10n.issuesFilterOpen
                        : l10n.issuesFilterClosed,
                    onSelected: (state) => setState(() => _state = state),
                  ),
                ],
              ),
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
                      ref.invalidate(myIssuesControllerProvider(query)),
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
                ref.refresh(myIssuesControllerProvider(query).future),
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

  Widget _tile(BuildContext context, Issue issue) {
    final status = LabFoxStatusColors.of(context);
    final open = issue.isOpen;
    final colors = open ? status.open : status.closed;
    final projectId = issue.projectId;
    final path = repoPathFromWebUrl(issue.webUrl);
    return WorkTile(
      icon: open ? Icons.adjust : Icons.check_circle_outline,
      iconColor: colors.foreground,
      title: issue.title,
      metadata: [
        StatusPill(label: open ? 'Open' : 'Closed', colors: colors, dot: true),
        // Cross-project rows carry the repo eyebrow so the origin is clear.
        MetaText(path == null ? '#${issue.iid}' : '$path #${issue.iid}'),
        if (issue.updatedAt != null) MetaText(timeAgo(issue.updatedAt!)),
        LabelChips(issue.labels),
        CommentCount(issue.commentCount),
      ],
      onTap: projectId == null
          ? null
          : () => context.go(Routes.issue(projectId, issue.iid)),
    );
  }
}
