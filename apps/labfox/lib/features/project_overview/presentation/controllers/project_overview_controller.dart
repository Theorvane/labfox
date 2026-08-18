import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/project_overview.dart';
import '../../data/project_overview_repository.dart';

final projectOverviewRepositoryProvider =
    FutureProvider<ProjectOverviewRepository?>((ref) async {
      final client = await ref.watch(gitLabClientProvider.future);
      return client == null ? null : ProjectOverviewRepository(client);
    });

/// Loads one project's overview. Keyed by project id so several can be cached.
class ProjectOverviewController
    extends FamilyAsyncNotifier<ProjectOverview, int> {
  @override
  Future<ProjectOverview> build(int projectId) async {
    final repository = await ref.watch(
      projectOverviewRepositoryProvider.future,
    );
    if (repository == null) {
      throw StateError('No authenticated account');
    }
    return repository.load(projectId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(
        projectOverviewRepositoryProvider.future,
      );
      if (repository == null) {
        throw StateError('No authenticated account');
      }
      return repository.load(arg);
    });
  }
}

final projectOverviewControllerProvider =
    AsyncNotifierProvider.family<
      ProjectOverviewController,
      ProjectOverview,
      int
    >(ProjectOverviewController.new);
