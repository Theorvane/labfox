import 'user.dart';

/// The approval state of a merge request.
///
/// GitLab returns `approved_by` as a list of wrapper objects, each holding a
/// `user`; this flattens them to the users. Approvals are not available on
/// every plan or instance, so the caller degrades gracefully when the endpoint
/// is absent rather than treating it as fatal.
class MergeRequestApprovals {
  const MergeRequestApprovals({
    required this.approvalsRequired,
    required this.userHasApproved,
    required this.approvedBy,
  });

  final int approvalsRequired;
  final bool userHasApproved;
  final List<User> approvedBy;

  int get approvedCount => approvedBy.length;

  factory MergeRequestApprovals.fromJson(Map<String, dynamic> json) {
    final approvers = (json['approved_by'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map((entry) => entry['user'])
        .whereType<Map<String, dynamic>>()
        .map(User.fromJson)
        .toList(growable: false);

    return MergeRequestApprovals(
      approvalsRequired: json['approvals_required'] as int? ?? 0,
      userHasApproved: json['user_has_approved'] as bool? ?? false,
      approvedBy: approvers,
    );
  }
}
