import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/history_repository.dart';

final historyRepositoryProvider = FutureProvider<HistoryRepository?>((
  ref,
) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : HistoryRepository(client);
});

/// Lists a project's branches.
class BranchesController extends FamilyAsyncNotifier<List<Branch>, int> {
  @override
  Future<List<Branch>> build(int projectId) async {
    final repo = await ref.watch(historyRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.branches(projectId);
  }

  /// Creates a branch [name] from [ref] and reloads the list so it appears.
  Future<void> create({required String name, required String ref}) async {
    final repo = await this.ref.read(historyRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    await repo.createBranch(projectId: arg, name: name, ref: ref);
    state = await AsyncValue.guard(() => repo.branches(arg));
  }
}

final branchesControllerProvider =
    AsyncNotifierProvider.family<BranchesController, List<Branch>, int>(
      BranchesController.new,
    );

/// Identifies a commit history: which project, which ref.
class CommitsRef {
  const CommitsRef({required this.projectId, required this.ref});

  final int projectId;
  final String ref;

  @override
  bool operator ==(Object other) =>
      other is CommitsRef && other.projectId == projectId && other.ref == ref;

  @override
  int get hashCode => Object.hash(projectId, ref);
}

/// Lists commits on a ref.
class CommitsController extends FamilyAsyncNotifier<List<Commit>, CommitsRef> {
  @override
  Future<List<Commit>> build(CommitsRef arg) async {
    final repo = await ref.watch(historyRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.commits(projectId: arg.projectId, ref: arg.ref);
  }
}

final commitsControllerProvider =
    AsyncNotifierProvider.family<CommitsController, List<Commit>, CommitsRef>(
      CommitsController.new,
    );

/// Identifies one commit.
class CommitRef {
  const CommitRef({required this.projectId, required this.sha});

  final int projectId;
  final String sha;

  @override
  bool operator ==(Object other) =>
      other is CommitRef && other.projectId == projectId && other.sha == sha;

  @override
  int get hashCode => Object.hash(projectId, sha);
}

/// Loads one commit's detail.
class CommitController extends FamilyAsyncNotifier<Commit, CommitRef> {
  @override
  Future<Commit> build(CommitRef arg) async {
    final repo = await ref.watch(historyRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.commit(projectId: arg.projectId, sha: arg.sha);
  }
}

final commitControllerProvider =
    AsyncNotifierProvider.family<CommitController, Commit, CommitRef>(
      CommitController.new,
    );
