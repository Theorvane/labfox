import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads a job's detail and its trace (log).
class JobRepository {
  JobRepository(this._client);

  final GitLabClient _client;

  Future<Job> get({required int projectId, required int jobId}) {
    return _client.jobs.get(projectId, jobId: jobId);
  }

  Future<String> trace({required int projectId, required int jobId}) {
    return _client.jobs.trace(projectId, jobId: jobId);
  }
}
