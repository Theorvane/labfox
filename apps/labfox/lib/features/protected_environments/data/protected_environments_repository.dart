import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Read-only protected environment rules for one authenticated account.
class ProtectedEnvironmentsRepository {
  const ProtectedEnvironmentsRepository(this.client);

  final GitLabClient client;

  Future<Paginated<ProtectedEnvironment>> list(int projectId, {int page = 1}) =>
      client.protectedEnvironments.list(projectId, page: page);

  Future<ProtectedEnvironment> get(int projectId, String name) =>
      client.protectedEnvironments.get(projectId, name);

  Future<Paginated<ProtectedEnvironment>> listGroup(
    int groupId, {
    int page = 1,
  }) => client.groupProtectedEnvironments.list(groupId, page: page);

  Future<ProtectedEnvironment> getGroup(int groupId, String name) =>
      client.groupProtectedEnvironments.get(groupId, name);
}
