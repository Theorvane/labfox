import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/pipelines_repository.dart';

final pipelinesRepositoryProvider = FutureProvider<PipelinesRepository?>((
  ref,
) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : PipelinesRepository(client);
});

/// Lists a project's pipelines.
class PipelinesController extends FamilyAsyncNotifier<List<Pipeline>, int> {
  @override
  Future<List<Pipeline>> build(int projectId) async {
    final repo = await ref.watch(pipelinesRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.list(projectId);
  }
}

final pipelinesControllerProvider =
    AsyncNotifierProvider.family<PipelinesController, List<Pipeline>, int>(
      PipelinesController.new,
    );

/// Identifies one pipeline.
class PipelineRef {
  const PipelineRef({required this.projectId, required this.pipelineId});

  final int projectId;
  final int pipelineId;

  @override
  bool operator ==(Object other) =>
      other is PipelineRef &&
      other.projectId == projectId &&
      other.pipelineId == pipelineId;

  @override
  int get hashCode => Object.hash(projectId, pipelineId);
}

/// The jobs of a pipeline, grouped by stage in first-seen order.
class PipelineJobsController
    extends FamilyAsyncNotifier<List<Job>, PipelineRef> {
  @override
  Future<List<Job>> build(PipelineRef arg) async {
    final repo = await ref.watch(pipelinesRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.jobs(projectId: arg.projectId, pipelineId: arg.pipelineId);
  }
}

final pipelineJobsControllerProvider =
    AsyncNotifierProvider.family<
      PipelineJobsController,
      List<Job>,
      PipelineRef
    >(PipelineJobsController.new);

/// A pipeline's own detail (status, ref, sha).
final pipelineDetailProvider = FutureProvider.family<Pipeline, PipelineRef>((
  ref,
  arg,
) async {
  final repo = await ref.watch(pipelinesRepositoryProvider.future);
  if (repo == null) {
    throw StateError('No authenticated account');
  }
  return repo.get(projectId: arg.projectId, pipelineId: arg.pipelineId);
});

/// Groups jobs by stage, preserving the order stages first appear.
Map<String, List<Job>> groupJobsByStage(List<Job> jobs) {
  final groups = <String, List<Job>>{};
  for (final job in jobs) {
    groups.putIfAbsent(job.stage ?? '', () => []).add(job);
  }
  return groups;
}

/// Runs retry / cancel on a pipeline, then refreshes the pipeline and its jobs
/// so the new status comes from the server, not a local guess.
class PipelineActionsController extends FamilyAsyncNotifier<void, PipelineRef> {
  @override
  Future<void> build(PipelineRef arg) async {}

  Future<void> retry() => _run(
    (repo) => repo.retry(projectId: arg.projectId, pipelineId: arg.pipelineId),
  );

  Future<void> cancel() => _run(
    (repo) => repo.cancel(projectId: arg.projectId, pipelineId: arg.pipelineId),
  );

  Future<void> _run(
    Future<void> Function(PipelinesRepository repo) action,
  ) async {
    final repo = await ref.read(pipelinesRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    state = const AsyncLoading();
    try {
      await action(repo);
      ref.invalidate(pipelineDetailProvider(arg));
      ref.invalidate(pipelineJobsControllerProvider(arg));
      state = const AsyncData(null);
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }
}

final pipelineActionsControllerProvider =
    AsyncNotifierProvider.family<PipelineActionsController, void, PipelineRef>(
      PipelineActionsController.new,
    );
