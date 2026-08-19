import 'package:gitlab_api/gitlab_api.dart';

import 'home_work.dart';

/// Assembles the home work feed from the account-scoped GitLab listings.
class HomeWorkRepository {
  HomeWorkRepository(this._client);

  final GitLabClient _client;

  /// The current user's review requests and assigned work, each capped to a
  /// short preview. The three requests run concurrently so the feed loads in
  /// one round trip's worth of latency, not three.
  Future<HomeWork> load(String username, {int perSection = 10}) async {
    final reviewRequests = _client.mergeRequests.listForReview(
      username,
      perPage: perSection,
    );
    final assignedMergeRequests = _client.mergeRequests.listAssignedToMe(
      perPage: perSection,
    );
    final assignedIssues = _client.issues.listAssignedToMe(perPage: perSection);

    return HomeWork(
      reviewRequests: (await reviewRequests).items,
      assignedMergeRequests: (await assignedMergeRequests).items,
      assignedIssues: (await assignedIssues).items,
    );
  }
}
