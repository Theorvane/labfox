import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import '../../commits/presentation/controllers/history_controllers.dart';

/// A project's branches. Tapping one browses the repository on that branch.
class BranchesScreen extends ConsumerWidget {
  const BranchesScreen({required this.projectId, super.key});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final l10n = AppLocalizations.of(context);
    final branches = widgetRef.watch(branchesControllerProvider(projectId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.branchesTitle)),
      body: branches.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.branchesError, textAlign: TextAlign.center),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton(
                  onPressed: () => widgetRef.invalidate(
                    branchesControllerProvider(projectId),
                  ),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.account_tree_outlined,
              title: l10n.branchesEmpty,
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _branchTile(context, l10n, items[index]),
          );
        },
      ),
    );
  }

  Widget _branchTile(
    BuildContext context,
    AppLocalizations l10n,
    Branch branch,
  ) {
    final theme = Theme.of(context);
    return WorkTile(
      icon: Icons.account_tree_outlined,
      title: branch.name,
      metadata: [
        if (branch.isDefault) MetaText(l10n.branchDefault),
        if (branch.isProtected)
          Icon(Icons.lock_outline, size: 14, color: theme.hintColor),
      ],
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(Routes.repository(projectId, branch.name)),
    );
  }
}
