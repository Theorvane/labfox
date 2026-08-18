import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/history_controllers.dart';

/// One commit's metadata: full message, author, date, and change counts.
///
/// The diff itself is M2 — it shares the diff viewer with merge requests — so
/// this shows the change counts, not the patch.
class CommitDetailScreen extends ConsumerWidget {
  const CommitDetailScreen({
    required this.projectId,
    required this.sha,
    super.key,
  });

  final int projectId;
  final String sha;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final l10n = AppLocalizations.of(context);
    final arg = CommitRef(projectId: projectId, sha: sha);
    final commit = widgetRef.watch(commitControllerProvider(arg));

    return Scaffold(
      appBar: AppBar(
        title: Text(commit.valueOrNull?.shortId ?? l10n.commitTitle),
      ),
      body: commit.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.commitError, textAlign: TextAlign.center),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton(
                  onPressed: () =>
                      widgetRef.invalidate(commitControllerProvider(arg)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (c) => ListView(
          padding: const EdgeInsets.all(LabFoxSpacing.md),
          children: [
            Text(c.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: LabFoxSpacing.sm),
            Text(
              [
                c.shortId,
                if (c.authorName != null) c.authorName!,
                if (c.authoredDate != null)
                  DateFormat.yMMMd().add_jm().format(c.authoredDate!.toLocal()),
              ].join(' · '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: LabFoxSpacing.md),
            OutlinedButton.icon(
              onPressed: () => context.go(Routes.commitChanges(projectId, sha)),
              icon: const Icon(Icons.difference_outlined, size: 18),
              label: Text(AppLocalizations.of(context).commitViewChanges),
            ),
            if (c.stats != null) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Row(
                children: [
                  Text(
                    '+${c.stats!.additions}',
                    style: const TextStyle(color: LabFoxColors.success),
                  ),
                  const SizedBox(width: LabFoxSpacing.md),
                  Text(
                    '-${c.stats!.deletions}',
                    style: const TextStyle(color: LabFoxColors.failure),
                  ),
                ],
              ),
            ],
            if (_body(c) != null) ...[
              const Divider(height: LabFoxSpacing.xl),
              SelectableText(
                _body(c)!,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// The message body below the title line, if the commit has one.
  String? _body(Commit c) {
    final message = c.message;
    if (message == null) {
      return null;
    }
    final trimmed = message.trimRight();
    if (trimmed == c.title || !trimmed.contains('\n')) {
      return null;
    }
    return trimmed.substring(trimmed.indexOf('\n')).trimLeft();
  }
}
