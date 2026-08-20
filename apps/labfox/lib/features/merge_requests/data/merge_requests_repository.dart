import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads a project's merge requests and single merge requests.
class MergeRequestsRepository {
  MergeRequestsRepository(this._client);

  final GitLabClient _client;

  Future<List<MergeRequest>> list({
    required int projectId,
    required MergeRequestState state,
  }) async {
    final page = await _client.mergeRequests.list(projectId, state: state);
    return page.items;
  }

  /// The current user's merge requests across every project, by scope.
  Future<List<MergeRequest>> listMine({
    required MergeRequestScope scope,
    required MergeRequestState state,
  }) async {
    final page = await _client.mergeRequests.listMine(
      scope: scope,
      state: state,
    );
    return page.items;
  }

  /// Open merge requests where [username] is a requested reviewer.
  Future<List<MergeRequest>> listForReview(
    String username, {
    required MergeRequestState state,
  }) async {
    final page = await _client.mergeRequests.listForReview(
      username,
      state: state,
    );
    return page.items;
  }

  Future<MergeRequest> get({required int projectId, required int iid}) {
    return _client.mergeRequests.get(projectId, iid: iid);
  }

  Future<MergeRequest> create({
    required int projectId,
    required String sourceBranch,
    required String targetBranch,
    required String title,
    String? description,
  }) {
    return _client.mergeRequests.create(
      projectId,
      sourceBranch: sourceBranch,
      targetBranch: targetBranch,
      title: title,
      description: description,
    );
  }
}
