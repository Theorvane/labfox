import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads the groups the signed-in user belongs to.
class GroupsRepository {
  GroupsRepository(this._client);

  final GitLabClient _client;

  Future<List<Group>> list() async {
    final page = await _client.groups.list();
    return page.items;
  }
}
