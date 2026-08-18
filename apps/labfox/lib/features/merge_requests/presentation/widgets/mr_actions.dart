import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/merge_requests_controllers.dart';
import '../controllers/mr_actions_controller.dart';

/// The approve / merge controls for a merge request.
///
/// Merge is irreversible, so it goes behind a confirmation dialog. Both actions
/// re-fetch the MR afterward; the widget never fabricates the merged state.
class MrActions extends ConsumerWidget {
  const MrActions({required this.mr, required this.projectId, super.key});

  final MergeRequest mr;
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mrRef = MergeRequestRef(projectId: projectId, iid: mr.iid);
    final actionState = ref.watch(mrActionsControllerProvider(mrRef));
    final approvals = ref.watch(mrApprovalsProvider(mrRef));
    final busy = actionState.isLoading;

    // A merged or closed MR has no actions.
    if (!mr.isOpen) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        approvals.maybeWhen(
          data: (a) => a == null
              ? const SizedBox.shrink()
              : _ApprovalSummary(approvals: a),
          orElse: () => const SizedBox.shrink(),
        ),
        const SizedBox(height: LabFoxSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: busy
                    ? null
                    : () => _toggleApproval(context, ref, mrRef, approvals),
                icon: const Icon(Icons.thumb_up_outlined, size: 18),
                label: Text(_approveLabel(l10n, approvals)),
              ),
            ),
            const SizedBox(width: LabFoxSpacing.sm),
            Expanded(
              child: FilledButton.icon(
                onPressed: busy
                    ? null
                    : () => _confirmMerge(context, ref, mrRef),
                icon: const Icon(Icons.merge, size: 18),
                label: Text(l10n.mrMerge),
              ),
            ),
          ],
        ),
        if (busy) ...[
          const SizedBox(height: LabFoxSpacing.sm),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  String _approveLabel(
    AppLocalizations l10n,
    AsyncValue<MergeRequestApprovals?> approvals,
  ) {
    final approved = approvals.valueOrNull?.userHasApproved ?? false;
    return approved ? l10n.mrUnapprove : l10n.mrApprove;
  }

  Future<void> _toggleApproval(
    BuildContext context,
    WidgetRef ref,
    MergeRequestRef mrRef,
    AsyncValue<MergeRequestApprovals?> approvals,
  ) async {
    final notifier = ref.read(mrActionsControllerProvider(mrRef).notifier);
    final approved = approvals.valueOrNull?.userHasApproved ?? false;
    final l10n = AppLocalizations.of(context);
    try {
      await (approved ? notifier.unapprove() : notifier.approve());
    } on GitLabException catch (error) {
      if (context.mounted) {
        _showError(context, _messageFor(error, l10n));
      }
    }
  }

  Future<void> _confirmMerge(
    BuildContext context,
    WidgetRef ref,
    MergeRequestRef mrRef,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.mrMergeConfirmTitle),
        content: Text(l10n.mrMergeConfirmBody('!${mr.iid}')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.mrMerge),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    try {
      await ref.read(mrActionsControllerProvider(mrRef).notifier).merge();
    } on GitLabException catch (error) {
      if (context.mounted) {
        _showError(context, _messageFor(error, l10n));
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _messageFor(GitLabException error, AppLocalizations l10n) {
    return switch (error) {
      GitLabNotMergeableException() => l10n.mrNotMergeable,
      GitLabForbiddenException() => l10n.mrActionForbidden,
      GitLabAuthException() => l10n.mrActionForbidden,
      _ => l10n.mrActionError,
    };
  }
}

class _ApprovalSummary extends StatelessWidget {
  const _ApprovalSummary({required this.approvals});

  final MergeRequestApprovals approvals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          approvals.approvedCount >= approvals.approvalsRequired
              ? Icons.check_circle_outline
              : Icons.pending_outlined,
          size: 16,
          color: LabFoxColors.pending,
        ),
        const SizedBox(width: LabFoxSpacing.xs),
        Text(
          l10n.mrApprovalsSummary(
            approvals.approvedCount,
            approvals.approvalsRequired,
          ),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
