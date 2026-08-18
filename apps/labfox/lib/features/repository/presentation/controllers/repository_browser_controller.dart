import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/repository_browser_repository.dart';

final repositoryBrowserRepositoryProvider =
    FutureProvider<RepositoryBrowserRepository?>((ref) async {
      final client = await ref.watch(gitLabClientProvider.future);
      return client == null ? null : RepositoryBrowserRepository(client);
    });

/// Identifies a directory to list: which project, which ref, which path.
class DirectoryRef {
  const DirectoryRef({
    required this.projectId,
    required this.ref,
    this.path = '',
  });

  final int projectId;
  final String ref;
  final String path;

  @override
  bool operator ==(Object other) =>
      other is DirectoryRef &&
      other.projectId == projectId &&
      other.ref == ref &&
      other.path == path;

  @override
  int get hashCode => Object.hash(projectId, ref, path);
}

/// Lists one directory of a repository. Keyed by (project, ref, path) so each
/// folder caches independently as the user navigates in and out.
class DirectoryController
    extends FamilyAsyncNotifier<List<RepositoryEntry>, DirectoryRef> {
  @override
  Future<List<RepositoryEntry>> build(DirectoryRef arg) async {
    final repository = await ref.watch(
      repositoryBrowserRepositoryProvider.future,
    );
    if (repository == null) {
      throw StateError('No authenticated account');
    }
    return repository.listDirectory(
      projectId: arg.projectId,
      ref: arg.ref,
      path: arg.path,
    );
  }
}

final directoryControllerProvider =
    AsyncNotifierProvider.family<
      DirectoryController,
      List<RepositoryEntry>,
      DirectoryRef
    >(DirectoryController.new);
