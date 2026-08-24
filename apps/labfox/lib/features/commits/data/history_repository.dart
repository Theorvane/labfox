import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads branches and commit history for a project.
class HistoryRepository {
  HistoryRepository(this._client);

  final GitLabClient _client;

  Future<Branch> createBranch({
    required int projectId,
    required String name,
    required String ref,
  }) {
    return _client.repository.createBranch(projectId, name: name, ref: ref);
  }

  Future<List<Branch>> branches(int projectId) async {
    final page = await _client.repository.branches(projectId);
    return page.items;
  }

  Future<List<Commit>> commits({
    required int projectId,
    required String ref,
  }) async {
    final page = await _client.repository.commits(projectId, ref: ref);
    return page.items;
  }

  Future<Commit> commit({required int projectId, required String sha}) {
    return _client.repository.commit(projectId, sha: sha);
  }
}
