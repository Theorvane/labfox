import 'package:design_system/design_system.dart';

import '../../l10n/app_localizations.dart';

/// The reason an open merge request cannot merge yet, from GitLab's
/// `detailed_merge_status` (present on list responses, so a row needs no extra
/// request). Returns null when the MR is mergeable or the status is unknown —
/// a clean row shows no chip. This is LabFox's take on the checks/reviews
/// signal GitHub surfaces on a pull request row.
({String label, StatusColor colors})? mrBlocker(
  String? detailedMergeStatus,
  AppLocalizations l10n,
  LabFoxStatusColors status,
) {
  return switch (detailedMergeStatus) {
    'conflict' ||
    'broken_status' => (label: l10n.mrBlockerConflicts, colors: status.closed),
    'ci_must_pass' => (
      label: l10n.mrBlockerChecksFailed,
      colors: status.closed,
    ),
    'ci_still_running' => (
      label: l10n.mrBlockerCiRunning,
      colors: status.running,
    ),
    'not_approved' => (
      label: l10n.mrBlockerNeedsApproval,
      colors: status.warning,
    ),
    'discussions_not_resolved' => (
      label: l10n.mrBlockerUnresolved,
      colors: status.warning,
    ),
    _ => null,
  };
}
