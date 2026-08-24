import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';

import 'repository_browser_controller.dart';

/// Identifies a file to read.
class FileRef {
  const FileRef({
    required this.projectId,
    required this.ref,
    required this.path,
  });

  final int projectId;
  final String ref;
  final String path;

  @override
  bool operator ==(Object other) =>
      other is FileRef &&
      other.projectId == projectId &&
      other.ref == ref &&
      other.path == path;

  @override
  int get hashCode => Object.hash(projectId, ref, path);
}

/// Reads one file's contents. Null means the file was not found.
class FileController extends FamilyAsyncNotifier<RepositoryFile?, FileRef> {
  @override
  Future<RepositoryFile?> build(FileRef arg) async {
    final repository = await ref.watch(
      repositoryBrowserRepositoryProvider.future,
    );
    if (repository == null) {
      throw StateError('No authenticated account');
    }
    return repository.readFile(
      projectId: arg.projectId,
      ref: arg.ref,
      path: arg.path,
    );
  }
}

final fileControllerProvider =
    AsyncNotifierProvider.family<FileController, RepositoryFile?, FileRef>(
      FileController.new,
    );
