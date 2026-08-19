import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/inbox_controllers.dart';

/// The current user's to-do inbox — the entry point of the core flow.
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final todos = ref.watch(inboxControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inboxTitle),
        actions: [
          if (todos.valueOrNull?.isNotEmpty ?? false)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: l10n.inboxMarkAllDone,
              onPressed: () => _markAllDone(context, ref),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(inboxControllerProvider.future),
        child: todos.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorState(
            message: l10n.inboxError,
            onRetry: () => ref.invalidate(inboxControllerProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return _EmptyState(message: l10n.inboxEmpty);
            }
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final todo = items[index];
                return Dismissible(
                  key: ValueKey(todo.id),
                  direction: DismissDirection.endToStart,
                  background: const _DismissBackground(),
                  onDismissed: (_) => _markDone(context, ref, todo.id),
                  child: _TodoTile(
                    todo: todo,
                    onTap: () => _openTarget(context, todo),
                    onMarkDone: () => _markDone(context, ref, todo.id),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _openTarget(BuildContext context, Todo todo) {
    final projectId = todo.project?.id;
    final iid = todo.target?.iid;
    if (projectId == null || iid == null) {
      return;
    }
    switch (todo.targetType) {
      case 'Issue':
        context.go(Routes.issue(projectId, iid));
      case 'MergeRequest':
        context.go(Routes.mergeRequest(projectId, iid));
    }
  }

  Future<void> _markDone(BuildContext context, WidgetRef ref, int id) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(inboxControllerProvider.notifier).markDone(id);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.inboxMarkDoneError)));
    }
  }

  Future<void> _markAllDone(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(inboxControllerProvider.notifier).markAllDone();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.inboxMarkDoneError)));
    }
  }
}

class _TodoTile extends StatelessWidget {
  const _TodoTile({
    required this.todo,
    required this.onTap,
    required this.onMarkDone,
  });

  final Todo todo;
  final VoidCallback onTap;
  final VoidCallback onMarkDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = LabFoxStatusColors.of(context);
    final colors = _reasonColors(todo.actionName, status);
    final canOpen =
        todo.project?.id != null &&
        todo.target?.iid != null &&
        (todo.targetType == 'Issue' || todo.targetType == 'MergeRequest');

    return WorkTile(
      icon: _iconFor(todo.targetType),
      iconColor: colors.foreground,
      title: todo.title,
      metadata: [
        StatusPill(label: _actionLabel(l10n, todo.actionName), colors: colors),
        if (todo.project != null) MetaText(_targetRef(todo)),
        if (todo.createdAt != null) MetaText(timeAgo(todo.createdAt!)),
      ],
      trailing: IconButton(
        icon: const Icon(Icons.check),
        tooltip: l10n.inboxMarkDone,
        onPressed: onMarkDone,
      ),
      onTap: canOpen ? onTap : null,
    );
  }

  /// The row eyebrow: the repo path, plus the target's number when it has one
  /// (`owner/repo #88` for an issue, `!88` for a merge request).
  static String _targetRef(Todo todo) {
    final path = todo.project!.pathWithNamespace;
    final iid = todo.target?.iid;
    if (iid == null) {
      return path;
    }
    final sigil = todo.targetType == 'MergeRequest' ? '!' : '#';
    return '$path $sigil$iid';
  }

  /// The reason's colour: failures read red, an approval request blue, a
  /// mention violet, everything else (assigned, added) green.
  static StatusColor _reasonColors(String action, LabFoxStatusColors s) {
    return switch (action) {
      'build_failed' || 'unmergeable' => s.closed,
      'approval_required' => s.running,
      'mentioned' || 'directly_addressed' => s.merged,
      _ => s.open,
    };
  }

  static IconData _iconFor(String? targetType) {
    switch (targetType) {
      case 'Issue':
        return Icons.adjust;
      case 'MergeRequest':
        return Icons.merge_outlined;
      case 'Commit':
        return Icons.commit;
      default:
        return Icons.notifications_outlined;
    }
  }

  static String _actionLabel(AppLocalizations l10n, String action) {
    switch (action) {
      case 'assigned':
        return l10n.inboxActionAssigned;
      case 'mentioned':
        return l10n.inboxActionMentioned;
      case 'build_failed':
        return l10n.inboxActionBuildFailed;
      case 'marked':
        return l10n.inboxActionMarked;
      case 'approval_required':
        return l10n.inboxActionApprovalRequired;
      case 'unmergeable':
        return l10n.inboxActionUnmergeable;
      case 'directly_addressed':
        return l10n.inboxActionDirectlyAddressed;
      default:
        return l10n.inboxActionMentioned;
    }
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primaryContainer,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: LabFoxSpacing.lg),
      child: Icon(Icons.check, color: theme.colorScheme.onPrimaryContainer),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // A single tile keeps the pull-to-refresh gesture available even when the
    // list is empty.
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 96),
          child: Column(
            children: [
              Icon(Icons.done_all, size: 48, color: theme.hintColor),
              const SizedBox(height: LabFoxSpacing.md),
              Text(message, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(LabFoxSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: 72),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
            ],
          ),
        ),
      ],
    );
  }
}
