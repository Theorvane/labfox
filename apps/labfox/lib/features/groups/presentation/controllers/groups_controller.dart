import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/groups_repository.dart';

final groupsRepositoryProvider = FutureProvider<GroupsRepository?>((ref) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : GroupsRepository(client);
});

/// The signed-in user's groups.
class GroupsController extends AsyncNotifier<List<Group>> {
  @override
  Future<List<Group>> build() async {
    final repo = await ref.watch(groupsRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.list();
  }
}

final groupsControllerProvider =
    AsyncNotifierProvider<GroupsController, List<Group>>(GroupsController.new);
