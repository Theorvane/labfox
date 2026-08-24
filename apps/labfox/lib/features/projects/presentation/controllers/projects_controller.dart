import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/projects_repository.dart';

final projectsRepositoryProvider = FutureProvider<ProjectsRepository?>((
  ref,
) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : ProjectsRepository(client);
});

/// Loads the signed-in account's projects.
class ProjectsController extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() async {
    final repository = await ref.watch(projectsRepositoryProvider.future);
    if (repository == null) {
      // Signed out: no projects to show. The router keeps this screen behind
      // authentication, so this is a defensive empty rather than an expected
      // state.
      return const [];
    }
    return repository.list();
  }

  /// Re-fetches, surfacing loading to the UI for pull-to-refresh.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(projectsRepositoryProvider.future);
      return repository == null ? <Project>[] : repository.list();
    });
  }
}

final projectsControllerProvider =
    AsyncNotifierProvider<ProjectsController, List<Project>>(
      ProjectsController.new,
    );
