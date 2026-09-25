import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/milestones_controller.dart';

/// A project milestone, restorable from its global GitLab ID.
class MilestoneDetailScreen extends ConsumerWidget {
  const MilestoneDetailScreen({
    required this.projectId,
    required this.milestoneId,
    super.key,
  });

  final int projectId;
  final int milestoneId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = MilestoneRef(projectId: projectId, milestoneId: milestoneId);
    final milestone = ref.watch(milestoneDetailProvider(key));
    return Scaffold(
      appBar: AppBar(
        title: Text(milestone.valueOrNull?.title ?? l10n.milestonesTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.milestones(projectId)),
        ),
      ),
      body: milestone.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.milestoneDetailError),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(
                onPressed: () => ref.invalidate(milestoneDetailProvider(key)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.refresh(milestoneDetailProvider(key).future),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= LabFoxBreakpoints.tablet;
              final metadata = _Metadata(milestone: data);
              final description = _Description(milestone: data);
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.all(LabFoxSpacing.md),
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 260, child: metadata),
                                  const SizedBox(width: LabFoxSpacing.md),
                                  Expanded(child: description),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  metadata,
                                  const SizedBox(height: LabFoxSpacing.md),
                                  description,
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.milestone});
  final GitLabMilestone milestone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    );
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              milestone.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: LabFoxSpacing.sm),
            Chip(
              label: Text(
                milestone.state == 'closed'
                    ? l10n.milestonesClosed
                    : l10n.milestonesActive,
              ),
            ),
            if (milestone.startDate != null) ...[
              const SizedBox(height: LabFoxSpacing.md),
              Text(
                l10n.milestoneStartDate,
                style: LabFoxTextRoles.of(context).sectionHeader,
              ),
              Text(dateFormat.format(milestone.startDate!)),
            ],
            if (milestone.dueDate != null) ...[
              const SizedBox(height: LabFoxSpacing.md),
              Text(
                l10n.milestoneDueDate,
                style: LabFoxTextRoles.of(context).sectionHeader,
              ),
              Text(dateFormat.format(milestone.dueDate!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.milestone});
  final GitLabMilestone milestone;

  @override
  Widget build(BuildContext context) =>
      milestone.description == null || milestone.description!.isEmpty
      ? const SizedBox.shrink()
      : Card.outlined(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.md),
            child: MarkdownViewer(data: milestone.description!),
          ),
        );
}
