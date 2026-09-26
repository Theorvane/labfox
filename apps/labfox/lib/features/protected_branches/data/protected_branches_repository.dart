import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Read-only project protection rules through one GitLab client.
class ProtectedBranchesRepository {
  const ProtectedBranchesRepository(this.client);

  final GitLabClient client;

  Future<Paginated<ProtectedBranch>> list(int projectId, {int page = 1}) =>
      client.protectedBranches.list(projectId, page: page);

  Future<ProtectedBranch> get(int projectId, String name) =>
      client.protectedBranches.get(projectId, name);
}
