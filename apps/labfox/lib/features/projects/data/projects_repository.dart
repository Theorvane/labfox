import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads projects for the signed-in account.
///
/// A thin wrapper over the client: it exists so the controller never builds a
/// client or knows about pagination headers. Network-only for now; a local
/// cache is a planned post-1.0 layer (see `.agents/docs/architecture.md`).
class ProjectsRepository {
  ProjectsRepository(this._client);

  final GitLabClient _client;

  Future<List<Project>> list() async {
    final page = await _client.projects.list();
    return page.items;
  }
}
