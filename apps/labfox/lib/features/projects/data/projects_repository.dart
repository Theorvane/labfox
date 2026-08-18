import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads projects for the signed-in account.
///
/// A thin wrapper over the client for this slice: it exists so the controller
/// never builds a client or knows about pagination headers. Caching (Drift)
/// lands with the offline work later.
class ProjectsRepository {
  ProjectsRepository(this._client);

  final GitLabClient _client;

  Future<List<Project>> list() async {
    final page = await _client.projects.list();
    return page.items;
  }
}
