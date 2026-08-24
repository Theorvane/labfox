import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/job_repository.dart';

final jobRepositoryProvider = FutureProvider<JobRepository?>((ref) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : JobRepository(client);
});

/// Identifies one job.
class JobRef {
  const JobRef({required this.projectId, required this.jobId});

  final int projectId;
  final int jobId;

  @override
  bool operator ==(Object other) =>
      other is JobRef && other.projectId == projectId && other.jobId == jobId;

  @override
  int get hashCode => Object.hash(projectId, jobId);
}

/// A job's detail (status, name, stage).
final jobDetailProvider = FutureProvider.family<Job, JobRef>((ref, arg) async {
  final repo = await ref.watch(jobRepositoryProvider.future);
  if (repo == null) {
    throw StateError('No authenticated account');
  }
  return repo.get(projectId: arg.projectId, jobId: arg.jobId);
});

/// A job's trace (log) text, a snapshot.
final jobTraceProvider = FutureProvider.family<String, JobRef>((
  ref,
  arg,
) async {
  final repo = await ref.watch(jobRepositoryProvider.future);
  if (repo == null) {
    throw StateError('No authenticated account');
  }
  return repo.trace(projectId: arg.projectId, jobId: arg.jobId);
});
