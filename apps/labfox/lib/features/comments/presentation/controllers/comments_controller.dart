import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/analytics/analytics.dart';
import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/comments_repository.dart';

final commentsRepositoryProvider = FutureProvider<CommentsRepository?>((
  ref,
) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : CommentsRepository(client);
});

/// Identifies a comment thread: which noteable, which project, which iid.
class CommentsRef {
  const CommentsRef({
    required this.type,
    required this.projectId,
    required this.iid,
  });

  final NoteableType type;
  final int projectId;
  final int iid;

  @override
  bool operator ==(Object other) =>
      other is CommentsRef &&
      other.type == type &&
      other.projectId == projectId &&
      other.iid == iid;

  @override
  int get hashCode => Object.hash(type, projectId, iid);
}

/// Loads a comment thread and posts to it.
///
/// This is the app's first mutation. After a successful post the thread is
/// re-fetched rather than optimistically appended, so what the user sees is the
/// server's copy — the id, the timestamp, and any rendering the server applied.
class CommentsController extends FamilyAsyncNotifier<List<Note>, CommentsRef> {
  @override
  Future<List<Note>> build(CommentsRef arg) async {
    final repo = await ref.watch(commentsRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.list(type: arg.type, projectId: arg.projectId, iid: arg.iid);
  }

  /// Posts a comment, then reloads the thread. Rethrows a domain exception so
  /// the composer can show a message (a 403 means the token cannot comment).
  Future<void> post(String body) async {
    final repo = await ref.read(commentsRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    await repo.post(
      type: arg.type,
      projectId: arg.projectId,
      iid: arg.iid,
      body: body,
    );
    // What kind of thing was commented on, never the comment itself.
    unawaited(
      ref.read(analyticsProvider).track('comment_posted', {
        'target': arg.type == NoteableType.mergeRequest
            ? 'merge_request'
            : 'issue',
      }),
    );
    state = await AsyncValue.guard(
      () => repo.list(type: arg.type, projectId: arg.projectId, iid: arg.iid),
    );
  }
}

final commentsControllerProvider =
    AsyncNotifierProvider.family<CommentsController, List<Note>, CommentsRef>(
      CommentsController.new,
    );
