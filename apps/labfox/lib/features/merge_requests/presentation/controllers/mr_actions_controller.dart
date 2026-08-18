import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/mr_actions_repository.dart';
import 'merge_requests_controllers.dart';

final mrActionsRepositoryProvider = FutureProvider<MrActionsRepository?>((
  ref,
) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : MrActionsRepository(client);
});

/// The approval state for a merge request, or null when the instance does not
/// expose approvals.
final mrApprovalsProvider =
    FutureProvider.family<MergeRequestApprovals?, MergeRequestRef>((
      ref,
      arg,
    ) async {
      final repo = await ref.watch(mrActionsRepositoryProvider.future);
      if (repo == null) {
        return null;
      }
      return repo.approvals(projectId: arg.projectId, iid: arg.iid);
    });

/// Runs approve / unapprove / merge, then refreshes the MR and its approvals so
/// the screen shows the server's state — never a locally fabricated one.
class MrActionsController extends FamilyAsyncNotifier<void, MergeRequestRef> {
  @override
  Future<void> build(MergeRequestRef arg) async {}

  Future<void> _refresh() async {
    ref.invalidate(mergeRequestControllerProvider(arg));
    ref.invalidate(mrApprovalsProvider(arg));
  }

  Future<void> approve() =>
      _run((repo) => repo.approve(projectId: arg.projectId, iid: arg.iid));

  Future<void> unapprove() =>
      _run((repo) => repo.unapprove(projectId: arg.projectId, iid: arg.iid));

  Future<void> merge() =>
      _run((repo) => repo.merge(projectId: arg.projectId, iid: arg.iid));

  /// Sets a loading state around the action so the UI can disable buttons, runs
  /// it, refreshes, and rethrows a domain exception for the caller to surface.
  Future<void> _run(
    Future<void> Function(MrActionsRepository repo) action,
  ) async {
    final repo = await ref.read(mrActionsRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    state = const AsyncLoading();
    try {
      await action(repo);
      await _refresh();
      state = const AsyncData(null);
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }
}

final mrActionsControllerProvider =
    AsyncNotifierProvider.family<MrActionsController, void, MergeRequestRef>(
      MrActionsController.new,
    );
