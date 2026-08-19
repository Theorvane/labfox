import 'package:gitlab_models/gitlab_models.dart';

/// The current user's actionable work for the home feed: merge requests they
/// were asked to review, and the merge requests and issues assigned to them.
///
/// A plain presentation aggregate, not a DTO — it is assembled from three
/// account-scoped listings, never deserialized from one response.
class HomeWork {
  const HomeWork({
    required this.reviewRequests,
    required this.assignedMergeRequests,
    required this.assignedIssues,
  });

  final List<MergeRequest> reviewRequests;
  final List<MergeRequest> assignedMergeRequests;
  final List<Issue> assignedIssues;

  /// True when there is nothing to show, so the feed can offer an all-clear
  /// state instead of three empty sections.
  bool get isEmpty =>
      reviewRequests.isEmpty &&
      assignedMergeRequests.isEmpty &&
      assignedIssues.isEmpty;
}
