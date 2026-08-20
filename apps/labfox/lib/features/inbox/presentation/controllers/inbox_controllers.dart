import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/inbox_repository.dart';

final inboxRepositoryProvider = FutureProvider<InboxRepository?>((ref) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : InboxRepository(client);
});

/// The current user's to-do items in one state — pending or done.
///
/// Marking an item done removes it optimistically so the list stays responsive,
/// and rolls the row back if the request fails — the server is the authority on
/// what is actually cleared. A cleared item belongs to the done list next, so
/// clearing invalidates it.
class InboxController extends FamilyAsyncNotifier<List<Todo>, TodoState> {
  @override
  Future<List<Todo>> build(TodoState arg) async {
    final repo = await ref.watch(inboxRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.list(state: arg);
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
      ref.invalidate(inboxControllerProvider(TodoState.done));
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
      ref.invalidate(inboxControllerProvider(TodoState.done));
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

final inboxControllerProvider =
    AsyncNotifierProvider.family<InboxController, List<Todo>, TodoState>(
      InboxController.new,
    );
