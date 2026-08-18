import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads directory listings and file contents for one project's repository.
class RepositoryBrowserRepository {
  RepositoryBrowserRepository(this._client);

  final GitLabClient _client;

  Future<List<RepositoryEntry>> listDirectory({
    required int projectId,
    required String ref,
    required String path,
  }) async {
    final page = await _client.repository.tree(projectId, ref: ref, path: path);
    return page.items;
  }

  Future<RepositoryFile?> readFile({
    required int projectId,
    required String ref,
    required String path,
  }) {
    return _client.repository.fileText(projectId, path: path, ref: ref);
  }
}
