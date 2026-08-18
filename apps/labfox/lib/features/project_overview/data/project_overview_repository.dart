import 'package:gitlab_api/gitlab_api.dart';

import 'project_overview.dart';

/// Loads a project's overview: its detail and its README together.
class ProjectOverviewRepository {
  ProjectOverviewRepository(this._client);

  final GitLabClient _client;

  Future<ProjectOverview> load(int projectId) async {
    final project = await _client.projects.get(projectId);
    // A project may have no default branch (empty repo) or no README; both are
    // normal and yield a null README rather than an error.
    final branch = project.defaultBranch;
    final readme = branch == null
        ? null
        : await _client.projects.readme(projectId, ref: branch);
    return ProjectOverview(project: project, readme: readme);
  }
}
