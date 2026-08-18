import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/inbox_repository.dart';

final inboxRepositoryProvider = FutureProvider<InboxRepository?>((ref) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : InboxRepository(client);
});

/// The current user's pending to-do items.
///
/// Marking an item done removes it optimistically so the list stays responsive,
/// and rolls the row back if the request fails — the server is the authority on
/// what is actually cleared.
class InboxController extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() async {
    final repo = await ref.watch(inboxRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.pending();
  }

  Future<void> markDone(int id) async {
    final repo = await ref.read(inboxRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    final previous = state.valueOrNull ?? const [];
    state = AsyncData(
      previous.where((todo) => todo.id != id).toList(growable: false),
    );
    try {
      await repo.markDone(id);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> markAllDone() async {
    final repo = await ref.read(inboxRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    final previous = state.valueOrNull ?? const [];
    state = const AsyncData([]);
    try {
      await repo.markAllDone();
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

final inboxControllerProvider =
    AsyncNotifierProvider<InboxController, List<Todo>>(InboxController.new);
