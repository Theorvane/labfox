import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads and clears the current user's to-do items.
class InboxRepository {
  InboxRepository(this._client);

  final GitLabClient _client;

  /// Every to-do item in [state], newest first — all pages, so a large inbox
  /// is never silently truncated.
  Future<List<Todo>> list({required TodoState state}) {
    return _client.todos.listAll(state: state);
  }

  Future<void> markDone(int id) => _client.todos.markDone(id);

  Future<void> markAllDone() => _client.todos.markAllDone();
}
