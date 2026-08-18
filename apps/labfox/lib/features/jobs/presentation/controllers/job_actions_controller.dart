import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/job_repository.dart';
import 'job_controllers.dart';

/// Runs retry / cancel / play on a job, then refreshes the job and its trace so
/// the new status comes from the server, not a local guess.
class JobActionsController extends FamilyAsyncNotifier<void, JobRef> {
  @override
  Future<void> build(JobRef arg) async {}

  Future<void> retry() =>
      _run((repo) => repo.retry(projectId: arg.projectId, jobId: arg.jobId));

  Future<void> cancel() =>
      _run((repo) => repo.cancel(projectId: arg.projectId, jobId: arg.jobId));

  Future<void> play() =>
      _run((repo) => repo.play(projectId: arg.projectId, jobId: arg.jobId));

  Future<void> _run(Future<void> Function(JobRepository repo) action) async {
    final repo = await ref.read(jobRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    state = const AsyncLoading();
    try {
      await action(repo);
      ref.invalidate(jobDetailProvider(arg));
      ref.invalidate(jobTraceProvider(arg));
      state = const AsyncData(null);
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }
}

final jobActionsControllerProvider =
    AsyncNotifierProvider.family<JobActionsController, void, JobRef>(
      JobActionsController.new,
    );
