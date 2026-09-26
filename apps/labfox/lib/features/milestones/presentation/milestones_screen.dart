import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/milestones_controller.dart';

/// Active and closed project milestones.
class MilestonesScreen extends ConsumerStatefulWidget {
  const MilestonesScreen({required this.projectId, super.key}) : groupId = null;

  const MilestonesScreen.group({required this.groupId, super.key})
    : projectId = null;

  final int? projectId;
  final int? groupId;

  @override
  ConsumerState<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends ConsumerState<MilestonesScreen> {
  String _state = 'active';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final projectId = widget.projectId;
    final groupId = widget.groupId;
    final projectKey = projectId == null
        ? null
        : MilestoneListRef(projectId: projectId, state: _state);
    final groupKey = groupId == null
        ? null
        : GroupMilestoneListRef(groupId: groupId, state: _state);
    final milestones = projectKey == null
        ? ref.watch(groupMilestoneListControllerProvider(groupKey!))
        : ref.watch(milestoneListControllerProvider(projectKey));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.milestonesTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(
                  groupId == null
                      ? Routes.projectOverview(projectId!)
                      : Routes.group(groupId),
                ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.md),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'active',
                  label: Text(l10n.milestonesActive),
                ),
                ButtonSegment(
                  value: 'closed',
                  label: Text(l10n.milestonesClosed),
                ),
              ],
              selected: {_state},
              onSelectionChanged: (value) =>
                  setState(() => _state = value.single),
            ),
          ),
          Expanded(
            child: milestones.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.milestonesError),
                    const SizedBox(height: LabFoxSpacing.md),
                    FilledButton(
                      onPressed: () => projectKey == null
                          ? ref.invalidate(
                              groupMilestoneListControllerProvider(groupKey!),
                            )
                          : ref.invalidate(
                              milestoneListControllerProvider(projectKey),
                            ),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
              data: (page) => page.items.isEmpty
                  ? Center(child: Text(l10n.milestonesEmpty))
                  : RefreshIndicator(
                      onRefresh: () => projectKey == null
                          ? ref.refresh(
                              groupMilestoneListControllerProvider(
                                groupKey!,
                              ).future,
                            )
                          : ref.refresh(
                              milestoneListControllerProvider(
                                projectKey,
                              ).future,
                            ),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 900),
                              child: Padding(
                                padding: const EdgeInsets.all(LabFoxSpacing.md),
                                child: Card.outlined(
                                  margin: EdgeInsets.zero,
                                  child: Column(
                                    children: [
                                      for (final milestone in page.items)
                                        ListTile(
                                          leading: const Icon(
                                            LabFoxIcons.milestone,
                                          ),
                                          title: Text(milestone.title),
                                          subtitle: milestone.dueDate == null
                                              ? null
                                              : Text(
                                                  DateFormat.yMMMd(
                                                    Localizations.localeOf(
                                                      context,
                                                    ).toString(),
                                                  ).format(milestone.dueDate!),
                                                ),
                                          trailing: const Icon(
                                            LabFoxIcons.chevron,
                                          ),
                                          onTap: () => context.push(
                                            groupId == null
                                                ? Routes.milestone(
                                                    projectId!,
                                                    milestone.id,
                                                  )
                                                : Routes.groupMilestone(
                                                    groupId,
                                                    milestone.id,
                                                  ),
                                          ),
                                        ),
                                      if (page.hasMore)
                                        TextButton(
                                          onPressed: () => projectKey == null
                                              ? ref
                                                    .read(
                                                      groupMilestoneListControllerProvider(
                                                        groupKey!,
                                                      ).notifier,
                                                    )
                                                    .loadMore()
                                              : ref
                                                    .read(
                                                      milestoneListControllerProvider(
                                                        projectKey,
                                                      ).notifier,
                                                    )
                                                    .loadMore(),
                                          child: Text(l10n.milestoneLoadMore),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
