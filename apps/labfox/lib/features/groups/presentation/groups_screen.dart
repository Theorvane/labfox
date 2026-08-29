import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/ui/link_opener.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/groups_controller.dart';

/// The groups the signed-in user belongs to.
///
/// A row opens the group on GitLab — group browsing (its projects, epics,
/// members) stays with the web UI for now; the list is the launcher.
class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final groups = ref.watch(groupsControllerProvider);
    final open = ref.watch(linkOpenerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.groupsTitle),
        // This route lives outside the navigation shell, so it carries its own
        // way back; entered with context.go there is no stack to pop.
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.home),
        ),
      ),
      body: groups.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.groupsError, textAlign: TextAlign.center),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton(
                  onPressed: () => ref.invalidate(groupsControllerProvider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(LabFoxSpacing.lg),
                child: Text(l10n.groupsEmpty, textAlign: TextAlign.center),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(groupsControllerProvider.future),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final group = items[index];
                final url = group.webUrl;
                return ProjectTile(
                  name: group.name,
                  path: group.fullPath,
                  description: group.description,
                  avatarUrl: group.avatarUrl,
                  visibility: group.visibility,
                  onTap: url == null ? null : () => open(Uri.parse(url)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
