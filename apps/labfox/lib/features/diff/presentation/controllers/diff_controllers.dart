import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/diff_repository.dart';

final diffRepositoryProvider = FutureProvider<DiffRepository?>((ref) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : DiffRepository(client);
});

/// Identifies a commit's changes.
class CommitDiffRef {
  const CommitDiffRef({required this.projectId, required this.sha});

  final int projectId;
  final String sha;

  @override
  bool operator ==(Object other) =>
      other is CommitDiffRef &&
      other.projectId == projectId &&
      other.sha == sha;

  @override
  int get hashCode => Object.hash(projectId, sha);
}

/// Loads a commit's file diffs.
class CommitDiffController
    extends FamilyAsyncNotifier<List<FileDiff>, CommitDiffRef> {
  @override
  Future<List<FileDiff>> build(CommitDiffRef arg) async {
    final repo = await ref.watch(diffRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.commitDiff(projectId: arg.projectId, sha: arg.sha);
  }
}

final commitDiffControllerProvider =
    AsyncNotifierProvider.family<
      CommitDiffController,
      List<FileDiff>,
      CommitDiffRef
    >(CommitDiffController.new);

/// Identifies a merge request's changes.
class MergeRequestDiffRef {
  const MergeRequestDiffRef({required this.projectId, required this.iid});

  final int projectId;
  final int iid;

  @override
  bool operator ==(Object other) =>
      other is MergeRequestDiffRef &&
      other.projectId == projectId &&
      other.iid == iid;

  @override
  int get hashCode => Object.hash(projectId, iid);
}

/// Loads a merge request's file diffs.
class MergeRequestDiffController
    extends FamilyAsyncNotifier<List<FileDiff>, MergeRequestDiffRef> {
  @override
  Future<List<FileDiff>> build(MergeRequestDiffRef arg) async {
    final repo = await ref.watch(diffRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.mergeRequestDiff(projectId: arg.projectId, iid: arg.iid);
  }
}

final mergeRequestDiffControllerProvider =
    AsyncNotifierProvider.family<
      MergeRequestDiffController,
      List<FileDiff>,
      MergeRequestDiffRef
    >(MergeRequestDiffController.new);
