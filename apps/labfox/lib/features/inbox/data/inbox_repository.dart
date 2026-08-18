import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads and clears the current user's to-do items.
class InboxRepository {
  InboxRepository(this._client);

  final GitLabClient _client;

  /// Every pending to-do item, newest first — all pages, so a large inbox is
  /// never silently truncated.
  Future<List<Todo>> pending() {
    return _client.todos.listAll(state: TodoState.pending);
  }

  Future<void> markDone(int id) => _client.todos.markDone(id);

  Future<void> markAllDone() => _client.todos.markAllDone();
}
