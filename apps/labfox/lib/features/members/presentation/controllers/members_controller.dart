import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/project_members_repository.dart';

final projectMembersRepositoryProvider =
    FutureProvider<ProjectMembersRepository?>((ref) async {
      final client = await ref.watch(gitLabClientProvider.future);
      return client == null ? null : ProjectMembersRepository(client);
    });

class MemberListRef {
  const MemberListRef({required this.projectId, required this.query});

  final int projectId;
  final String query;

  @override
  bool operator ==(Object other) =>
      other is MemberListRef &&
      projectId == other.projectId &&
      query == other.query;

  @override
  int get hashCode => Object.hash(projectId, query);
}

/// Server-side member search and response-header pagination.
class ProjectMembersController
    extends FamilyAsyncNotifier<Paginated<ProjectMember>, MemberListRef> {
  bool _loadingMore = false;

  @override
  Future<Paginated<ProjectMember>> build(MemberListRef arg) async {
    final repository = await ref.watch(projectMembersRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    return repository.list(
      arg.projectId,
      query: arg.query.isEmpty ? null : arg.query,
    );
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    _loadingMore = true;
    try {
      final repository = await ref.read(
        projectMembersRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.list(
        arg.projectId,
        query: arg.query.isEmpty ? null : arg.query,
        page: page,
      );
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

final projectMembersControllerProvider =
    AsyncNotifierProvider.family<
      ProjectMembersController,
      Paginated<ProjectMember>,
      MemberListRef
    >(ProjectMembersController.new);
