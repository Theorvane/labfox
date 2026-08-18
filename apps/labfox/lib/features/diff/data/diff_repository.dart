import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads the file diffs for a commit or a merge request.
class DiffRepository {
  DiffRepository(this._client);

  final GitLabClient _client;

  Future<List<FileDiff>> commitDiff({
    required int projectId,
    required String sha,
  }) {
    return _client.repository.commitDiff(projectId, sha: sha);
  }

  Future<List<FileDiff>> mergeRequestDiff({
    required int projectId,
    required int iid,
  }) {
    return _client.mergeRequests.diffs(projectId, iid: iid);
  }
}
