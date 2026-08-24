import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads and clears the current user's to-do items.
class InboxRepository {
  InboxRepository(this._client);

  final GitLabClient _client;

  /// Every to-do item matching the filters, newest first — all pages, so a
  /// large inbox is never silently truncated. Null [type]/[action] mean
  /// unfiltered.
  Future<List<Todo>> list({
    required TodoState state,
    TodoType? type,
    TodoAction? action,
  }) {
    return _client.todos.listAll(state: state, type: type, action: action);
  }

  Future<void> markDone(int id) => _client.todos.markDone(id);

  Future<void> markAllDone() => _client.todos.markAllDone();
}
