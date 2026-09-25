import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Read-only project milestones through one authenticated GitLab client.
class MilestonesRepository {
  const MilestonesRepository(this.client);

  final GitLabClient client;

  Future<Paginated<GitLabMilestone>> list(
    int projectId, {
    required String state,
    int page = 1,
  }) => client.milestones.list(projectId, state: state, page: page);

  Future<GitLabMilestone> get(int projectId, int milestoneId) =>
      client.milestones.get(projectId, milestoneId);
}
