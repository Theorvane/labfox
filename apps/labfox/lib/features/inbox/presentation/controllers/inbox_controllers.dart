import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/analytics/analytics.dart';
import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/inbox_repository.dart';

final inboxRepositoryProvider = FutureProvider<InboxRepository?>((ref) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : InboxRepository(client);
});

/// Identifies an inbox list: which state, and the optional type and reason
/// filters.
class InboxQuery {
  const InboxQuery({this.state = TodoState.pending, this.type, this.action});

  final TodoState state;
  final TodoType? type;
  final TodoAction? action;

  /// The same filters pointed at the done list — what a cleared item joins.
  InboxQuery get asDone =>
      InboxQuery(state: TodoState.done, type: type, action: action);

  @override
  bool operator ==(Object other) =>
      other is InboxQuery &&
      other.state == state &&
      other.type == type &&
      other.action == action;

  @override
  int get hashCode => Object.hash(state, type, action);
}

/// The current user's to-do items for one query.
///
/// Marking an item done removes it optimistically so the list stays responsive,
/// and rolls the row back if the request fails — the server is the authority on
/// what is actually cleared. A cleared item belongs to the matching done list
/// next, so clearing invalidates it.
class InboxController extends FamilyAsyncNotifier<List<Todo>, InboxQuery> {
  @override
  Future<List<Todo>> build(InboxQuery arg) async {
    final repo = await ref.watch(inboxRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.list(state: arg.state, type: arg.type, action: arg.action);
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
      unawaited(ref.read(analyticsProvider).track('todo_cleared'));
      ref.invalidate(inboxControllerProvider(arg.asDone));
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
      ref.invalidate(inboxControllerProvider(arg.asDone));
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

final inboxControllerProvider =
    AsyncNotifierProvider.family<InboxController, List<Todo>, InboxQuery>(
      InboxController.new,
    );
