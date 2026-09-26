import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/protected_environments_controller.dart';

/// One rule, restorable from its project and environment name.
class ProtectedEnvironmentDetailScreen extends ConsumerWidget {
  const ProtectedEnvironmentDetailScreen({
    required this.projectId,
    required this.name,
    super.key,
  });

  final int projectId;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = ProtectedEnvironmentRef(projectId: projectId, name: name);
    final rule = ref.watch(protectedEnvironmentDetailProvider(key));
    return Scaffold(
      appBar: AppBar(
        title: Text(rule.valueOrNull?.name ?? l10n.protectedEnvironmentsTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.protectedEnvironments(projectId)),
        ),
      ),
      body: rule.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error is GitLabForbiddenException
                    ? l10n.protectedEnvironmentsUnavailable
                    : l10n.protectedEnvironmentsError,
              ),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(protectedEnvironmentDetailProvider(key)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () =>
              ref.refresh(protectedEnvironmentDetailProvider(key).future),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= LabFoxBreakpoints.tablet;
              final summary = Card.outlined(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(LabFoxSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: LabFoxSpacing.sm),
                      Text(
                        l10n.protectedEnvironmentApprovalCount(
                          data.requiredApprovalCount,
                        ),
                      ),
                    ],
                  ),
                ),
              );
              final permissions = Column(
                children: [
                  _AccessCard(
                    title: l10n.protectedEnvironmentDeployAccess,
                    entries: data.deployAccessLevels,
                  ),
                  const SizedBox(height: LabFoxSpacing.md),
                  _AccessCard(
                    title: l10n.protectedEnvironmentApprovalRules,
                    entries: data.approvalRules,
                    showRequiredApprovals: true,
                  ),
                ],
              );
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
                                  SizedBox(width: 300, child: summary),
                                  const SizedBox(width: LabFoxSpacing.md),
                                  Expanded(child: permissions),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  summary,
                                  const SizedBox(height: LabFoxSpacing.md),
                                  permissions,
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

class _AccessCard extends StatelessWidget {
  const _AccessCard({
    required this.title,
    required this.entries,
    this.showRequiredApprovals = false,
  });

  final String title;
  final List<ProtectedEnvironmentAccess> entries;
  final bool showRequiredApprovals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: LabFoxTextRoles.of(context).sectionHeader),
            const SizedBox(height: LabFoxSpacing.sm),
            if (entries.isEmpty)
              Text(l10n.protectedBranchNoAccess)
            else
              for (final entry in entries)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LabFoxIcons.person),
                  title: Text(
                    entry.description ?? l10n.protectedBranchNoAccess,
                  ),
                  subtitle:
                      showRequiredApprovals && entry.requiredApprovals != null
                      ? Text(
                          l10n.protectedEnvironmentApprovalCount(
                            entry.requiredApprovals!,
                          ),
                        )
                      : null,
                ),
          ],
        ),
      ),
    );
  }
}
