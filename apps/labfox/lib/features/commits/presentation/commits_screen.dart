import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/history_controllers.dart';

/// Commits on a ref, most recent first.
class CommitsScreen extends ConsumerWidget {
  const CommitsScreen({required this.projectId, required this.ref, super.key});

  final int projectId;
  final String ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final l10n = AppLocalizations.of(context);
    final arg = CommitsRef(projectId: projectId, ref: ref);
    final commits = widgetRef.watch(commitsControllerProvider(arg));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.commitsTitle)),
      body: commits.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorRetry(
          message: l10n.commitsError,
          onRetry: () => widgetRef.invalidate(commitsControllerProvider(arg)),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.commitsEmpty));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => _CommitTile(
              commit: items[index],
              onTap: () =>
                  context.go(Routes.commit(projectId, items[index].id)),
            ),
          );
        },
      ),
    );
  }
}

class _CommitTile extends StatelessWidget {
  const _CommitTile({required this.commit, required this.onTap});

  final Commit commit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleParts = [
      commit.shortId,
      if (commit.authorName != null) commit.authorName!,
      if (commit.authoredDate != null)
        DateFormat.yMMMd().format(commit.authoredDate!.toLocal()),
    ];
    return ListTile(
      title: Text(commit.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        subtitleParts.join(' · '),
        style: theme.textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: LabFoxSpacing.md),
            FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
