import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads pipelines and their jobs for a project.
class PipelinesRepository {
  PipelinesRepository(this._client);

  final GitLabClient _client;

  Future<List<Pipeline>> list(int projectId) async {
    final page = await _client.pipelines.list(projectId);
    return page.items;
  }

  Future<Pipeline> get({required int projectId, required int pipelineId}) {
    return _client.pipelines.get(projectId, pipelineId: pipelineId);
  }

  Future<List<Job>> jobs({required int projectId, required int pipelineId}) {
    return _client.pipelines.jobs(projectId, pipelineId: pipelineId);
  }
}
