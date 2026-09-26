import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/protected_environments_controller.dart';

/// Project protected deployment environments.
class ProtectedEnvironmentsScreen extends ConsumerWidget {
  const ProtectedEnvironmentsScreen({required this.projectId, super.key});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rules = ref.watch(protectedEnvironmentsControllerProvider(projectId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.protectedEnvironmentsTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.environments(projectId)),
        ),
      ),
      body: rules.when(
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
                onPressed: () => ref.invalidate(
                  protectedEnvironmentsControllerProvider(projectId),
                ),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (page) => page.items.isEmpty
            ? EmptyState(
                icon: LabFoxIcons.private,
                title: l10n.protectedEnvironmentsEmpty,
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(
                  protectedEnvironmentsControllerProvider(projectId).future,
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
                                for (final rule in page.items)
                                  ListTile(
                                    leading: const Icon(LabFoxIcons.private),
                                    title: Text(rule.name),
                                    subtitle: rule.requiredApprovalCount > 0
                                        ? Text(
                                            l10n.protectedEnvironmentApprovalCount(
                                              rule.requiredApprovalCount,
                                            ),
                                          )
                                        : null,
                                    trailing: const Icon(LabFoxIcons.chevron),
                                    onTap: () => context.push(
                                      Routes.protectedEnvironment(
                                        projectId,
                                        rule.name,
                                      ),
                                    ),
                                  ),
                                if (page.hasMore)
                                  TextButton(
                                    onPressed: () => ref
                                        .read(
                                          protectedEnvironmentsControllerProvider(
                                            projectId,
                                          ).notifier,
                                        )
                                        .loadMore(),
                                    child: Text(
                                      l10n.protectedEnvironmentsLoadMore,
                                    ),
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
    );
  }
}
