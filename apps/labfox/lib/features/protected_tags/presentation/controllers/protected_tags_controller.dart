import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/protected_tags_repository.dart';

final protectedTagsRepositoryProvider =
    FutureProvider<ProtectedTagsRepository?>((ref) async {
      final client = await ref.watch(gitLabClientProvider.future);
      return client == null ? null : ProtectedTagsRepository(client);
    });

class ProtectedTagsController
    extends FamilyAsyncNotifier<Paginated<ProtectedTag>, int> {
  bool _loadingMore = false;

  @override
  Future<Paginated<ProtectedTag>> build(int projectId) async {
    final repository = await ref.watch(protectedTagsRepositoryProvider.future);
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
      final repository = await ref.read(protectedTagsRepositoryProvider.future);
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

final protectedTagsControllerProvider =
    AsyncNotifierProvider.family<
      ProtectedTagsController,
      Paginated<ProtectedTag>,
      int
    >(ProtectedTagsController.new);

class ProtectedTagRef {
  const ProtectedTagRef({required this.projectId, required this.name});

  final int projectId;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is ProtectedTagRef &&
      projectId == other.projectId &&
      name == other.name;

  @override
  int get hashCode => Object.hash(projectId, name);
}

final protectedTagDetailProvider =
    FutureProvider.family<ProtectedTag, ProtectedTagRef>((ref, key) async {
      final repository = await ref.watch(
        protectedTagsRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      return repository.get(key.projectId, key.name);
    });
