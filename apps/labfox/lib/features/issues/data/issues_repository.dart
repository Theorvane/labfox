import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads a project's issues and single issues.
class IssuesRepository {
  IssuesRepository(this._client);

  final GitLabClient _client;

  Future<List<Issue>> list({
    required int projectId,
    required IssueState state,
  }) async {
    final page = await _client.issues.list(projectId, state: state);
    return page.items;
  }

  Future<Issue> get({required int projectId, required int iid}) {
    return _client.issues.get(projectId, iid: iid);
  }
}
