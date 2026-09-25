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
  const MilestonesScreen({required this.projectId, super.key});

  final int projectId;

  @override
  ConsumerState<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends ConsumerState<MilestonesScreen> {
  String _state = 'active';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final key = MilestoneListRef(projectId: widget.projectId, state: _state);
    final milestones = ref.watch(milestoneListControllerProvider(key));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.milestonesTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.projectOverview(widget.projectId)),
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
                      onPressed: () =>
                          ref.invalidate(milestoneListControllerProvider(key)),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
              data: (page) => page.items.isEmpty
                  ? Center(child: Text(l10n.milestonesEmpty))
                  : RefreshIndicator(
                      onRefresh: () => ref.refresh(
                        milestoneListControllerProvider(key).future,
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
                                            Routes.milestone(
                                              widget.projectId,
                                              milestone.id,
                                            ),
                                          ),
                                        ),
                                      if (page.hasMore)
                                        TextButton(
                                          onPressed: () => ref
                                              .read(
                                                milestoneListControllerProvider(
                                                  key,
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
