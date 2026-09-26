import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/protected_environments_repository.dart';

final protectedEnvironmentsRepositoryProvider =
    FutureProvider<ProtectedEnvironmentsRepository?>((ref) async {
      final client = await ref.watch(gitLabClientProvider.future);
      return client == null ? null : ProtectedEnvironmentsRepository(client);
    });

class ProtectedEnvironmentsController
    extends FamilyAsyncNotifier<Paginated<ProtectedEnvironment>, int> {
  bool _loadingMore = false;

  @override
  Future<Paginated<ProtectedEnvironment>> build(int projectId) async {
    final repository = await ref.watch(
      protectedEnvironmentsRepositoryProvider.future,
    );
    if (repository == null) throw StateError('No authenticated account');
    return repository.list(projectId);
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    _loadingMore = true;
    try {
      final repository = await ref.read(
        protectedEnvironmentsRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.list(arg, page: page);
      state = AsyncData(
        Paginated(
          items: [...current.items, ...next.items],
          nextPage: next.nextPage,
          total: next.total,
          totalPages: next.totalPages,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      _loadingMore = false;
    }
  }
}

final protectedEnvironmentsControllerProvider =
    AsyncNotifierProvider.family<
      ProtectedEnvironmentsController,
      Paginated<ProtectedEnvironment>,
      int
    >(ProtectedEnvironmentsController.new);

class ProtectedEnvironmentRef {
  const ProtectedEnvironmentRef({required this.projectId, required this.name});

  final int projectId;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is ProtectedEnvironmentRef &&
      projectId == other.projectId &&
      name == other.name;

  @override
  int get hashCode => Object.hash(projectId, name);
}

final protectedEnvironmentDetailProvider =
    FutureProvider.family<ProtectedEnvironment, ProtectedEnvironmentRef>((
      ref,
      key,
    ) async {
      final repository = await ref.watch(
        protectedEnvironmentsRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      return repository.get(key.projectId, key.name);
    });
