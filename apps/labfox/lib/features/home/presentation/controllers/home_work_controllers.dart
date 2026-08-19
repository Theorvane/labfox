import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/home_work.dart';
import '../../data/home_work_repository.dart';

final homeWorkRepositoryProvider = FutureProvider<HomeWorkRepository?>((
  ref,
) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : HomeWorkRepository(client);
});

/// The current user's home work feed: review requests and assigned work.
class HomeWorkController extends AsyncNotifier<HomeWork> {
  @override
  Future<HomeWork> build() async {
    final repo = await ref.watch(homeWorkRepositoryProvider.future);
    final account = ref.watch(currentAccountProvider);
    if (repo == null || account == null) {
      throw StateError('No authenticated account');
    }
    return repo.load(account.user.username);
  }
}

final homeWorkControllerProvider =
    AsyncNotifierProvider<HomeWorkController, HomeWork>(HomeWorkController.new);
