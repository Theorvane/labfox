import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/repository_browser_controller.dart';

/// Lists one directory of a project's repository.
///
/// A folder descends into another browser at its path; a file opens the viewer.
/// The screen is stateless in the path — the path is a route parameter, so deep
/// linking and back navigation work without holding a stack in memory.
class RepositoryBrowserScreen extends ConsumerWidget {
  const RepositoryBrowserScreen({
    required this.projectId,
    required this.ref,
    this.path = '',
    super.key,
  });

  final int projectId;
  final String ref;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final l10n = AppLocalizations.of(context);
    final dir = DirectoryRef(projectId: projectId, ref: ref, path: path);
    final entries = widgetRef.watch(directoryControllerProvider(dir));
    final title = path.isEmpty ? l10n.repositoryTitle : path.split('/').last;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // The current branch, tappable to pick another. At the root it also
          // labels which ref is being browsed.
          TextButton.icon(
            onPressed: () => context.go(Routes.branches(projectId)),
            icon: const Icon(Icons.account_tree_outlined, size: 16),
            label: Text(ref, overflow: TextOverflow.ellipsis),
          ),
          IconButton(
            tooltip: l10n.commitsTitle,
            icon: const Icon(Icons.history),
            onPressed: () => context.go(Routes.commits(projectId, ref)),
          ),
        ],
      ),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.repositoryError, textAlign: TextAlign.center),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton(
                  onPressed: () =>
                      widgetRef.invalidate(directoryControllerProvider(dir)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.repositoryEmpty));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => _entryTile(context, items[index]),
          );
        },
      ),
    );
  }

  Widget _entryTile(BuildContext context, RepositoryEntry entry) {
    return ListTile(
      leading: Icon(
        entry.isDirectory
            ? Icons.folder_outlined
            : Icons.insert_drive_file_outlined,
        color: entry.isDirectory ? LabFoxColors.orange : LabFoxColors.pending,
      ),
      title: Text(entry.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: entry.isDirectory ? const Icon(Icons.chevron_right) : null,
      onTap: () {
        if (entry.isDirectory) {
          context.go(Routes.repositoryPath(projectId, ref, entry.path));
        } else {
          context.go(Routes.file(projectId, ref, entry.path));
        }
      },
    );
  }
}
