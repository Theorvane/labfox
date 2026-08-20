import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/merge_requests_repository.dart';

final mergeRequestsRepositoryProvider =
    FutureProvider<MergeRequestsRepository?>((ref) async {
      final client = await ref.watch(gitLabClientProvider.future);
      return client == null ? null : MergeRequestsRepository(client);
    });

/// Identifies a merge request list: which project, which state filter.
class MergeRequestsQuery {
  const MergeRequestsQuery({
    required this.projectId,
    this.state = MergeRequestState.opened,
  });

  final int projectId;
  final MergeRequestState state;

  @override
  bool operator ==(Object other) =>
      other is MergeRequestsQuery &&
      other.projectId == projectId &&
      other.state == state;

  @override
  int get hashCode => Object.hash(projectId, state);
}

/// Lists merge requests for a query.
class MergeRequestsController
    extends FamilyAsyncNotifier<List<MergeRequest>, MergeRequestsQuery> {
  @override
  Future<List<MergeRequest>> build(MergeRequestsQuery arg) async {
    final repo = await ref.watch(mergeRequestsRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.list(projectId: arg.projectId, state: arg.state);
  }
}

final mergeRequestsControllerProvider =
    AsyncNotifierProvider.family<
      MergeRequestsController,
      List<MergeRequest>,
      MergeRequestsQuery
    >(MergeRequestsController.new);

/// Identifies one merge request by its per-project iid.
class MergeRequestRef {
  const MergeRequestRef({required this.projectId, required this.iid});

  final int projectId;
  final int iid;

  @override
  bool operator ==(Object other) =>
      other is MergeRequestRef &&
      other.projectId == projectId &&
      other.iid == iid;

  @override
  int get hashCode => Object.hash(projectId, iid);
}

/// Loads one merge request's detail.
class MergeRequestController
    extends FamilyAsyncNotifier<MergeRequest, MergeRequestRef> {
  @override
  Future<MergeRequest> build(MergeRequestRef arg) async {
    final repo = await ref.watch(mergeRequestsRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.get(projectId: arg.projectId, iid: arg.iid);
  }
}

final mergeRequestControllerProvider =
    AsyncNotifierProvider.family<
      MergeRequestController,
      MergeRequest,
      MergeRequestRef
    >(MergeRequestController.new);

/// Creates a new merge request, then invalidates the open-MR list so it appears
/// on return. Exposes an [AsyncValue] so the form can show progress and errors.
class NewMergeRequestController extends AutoDisposeAsyncNotifier<void> {
  @override
  void build() {}

  Future<MergeRequest> submit({
    required int projectId,
    required String sourceBranch,
    required String targetBranch,
    required String title,
    String? description,
  }) async {
    final repo = await ref.read(mergeRequestsRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    state = const AsyncLoading();
    try {
      final mr = await repo.create(
        projectId: projectId,
        sourceBranch: sourceBranch,
        targetBranch: targetBranch,
        title: title,
        description: description,
      );
      state = const AsyncData(null);
      ref.invalidate(mergeRequestsControllerProvider);
      return mr;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }
}

final newMergeRequestControllerProvider =
    AutoDisposeAsyncNotifierProvider<NewMergeRequestController, void>(
      NewMergeRequestController.new,
    );

/// Whose merge requests the account-level list shows.
enum MyMergeRequestScope { assigned, reviewRequests, created }

/// Identifies an account-level merge request list.
class MyMergeRequestsQuery {
  const MyMergeRequestsQuery({required this.scope, required this.state});

  final MyMergeRequestScope scope;
  final MergeRequestState state;

  @override
  bool operator ==(Object other) =>
      other is MyMergeRequestsQuery &&
      other.scope == scope &&
      other.state == state;

  @override
  int get hashCode => Object.hash(scope, state);
}

/// The current user's merge requests across every project. Review requests
/// filter by the signed-in username, since GitLab has no scope for them.
class MyMergeRequestsController
    extends FamilyAsyncNotifier<List<MergeRequest>, MyMergeRequestsQuery> {
  @override
  Future<List<MergeRequest>> build(MyMergeRequestsQuery arg) async {
    final repo = await ref.watch(mergeRequestsRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    if (arg.scope == MyMergeRequestScope.reviewRequests) {
      final account = ref.watch(currentAccountProvider);
      if (account == null) {
        throw StateError('No authenticated account');
      }
      return repo.listForReview(account.user.username, state: arg.state);
    }
    return repo.listMine(
      scope: arg.scope == MyMergeRequestScope.created
          ? MergeRequestScope.createdByMe
          : MergeRequestScope.assignedToMe,
      state: arg.state,
    );
  }
}

final myMergeRequestsControllerProvider =
    AsyncNotifierProvider.family<
      MyMergeRequestsController,
      List<MergeRequest>,
      MyMergeRequestsQuery
    >(MyMergeRequestsController.new);
