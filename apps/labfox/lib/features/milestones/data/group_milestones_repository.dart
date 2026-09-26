import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Read-only group milestones through one authenticated GitLab client.
class GroupMilestonesRepository {
  const GroupMilestonesRepository(this.client);

  final GitLabClient client;

  Future<Paginated<GitLabMilestone>> list(
    int groupId, {
    required String state,
    int page = 1,
  }) => client.groupMilestones.list(groupId, state: state, page: page);

  Future<GitLabMilestone> get(int groupId, int milestoneId) =>
      client.groupMilestones.get(groupId, milestoneId);
}
