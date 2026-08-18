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

  Future<MergeRequest> get({required int projectId, required int iid}) {
    return _client.mergeRequests.get(projectId, iid: iid);
  }
}
