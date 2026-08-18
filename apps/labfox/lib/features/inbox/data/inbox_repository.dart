import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads and clears the current user's to-do items.
class InboxRepository {
  InboxRepository(this._client);

  final GitLabClient _client;

  /// The pending to-do items, newest first.
  Future<List<Todo>> pending() async {
    final page = await _client.todos.list(state: TodoState.pending);
    return page.items;
  }

  Future<void> markDone(int id) => _client.todos.markDone(id);

  Future<void> markAllDone() => _client.todos.markAllDone();
}
