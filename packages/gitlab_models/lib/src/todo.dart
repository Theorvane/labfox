import 'package:freezed_annotation/freezed_annotation.dart';

import 'project.dart';
import 'user.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

/// One item in the current user's To-do list — the inbox that opens the core
/// flow ("Check notifications").
///
/// A todo points at a `target` (an issue, merge request, commit, …). Only the
/// subset the inbox renders and navigates from is kept; unknown fields are
/// ignored. `project` is absent for group- or epic-scoped todos, so it is
/// nullable.
@freezed
abstract class Todo with _$Todo {
  const factory Todo({
    required int id,
    required String state,
    @JsonKey(name: 'action_name') @Default('') String actionName,
    @JsonKey(name: 'target_type') String? targetType,
    @JsonKey(name: 'target_url') String? targetUrl,
    String? body,
    User? author,
    Project? project,
    TodoTarget? target,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Todo;

  const Todo._();

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  /// A todo the user has not cleared yet.
  bool get isPending => state == 'pending';

  /// What the row shows as the headline: the target's own title when present,
  /// otherwise the server-rendered `body`, which already reads as a sentence.
  String get title => target?.title ?? body ?? '';
}

/// The issue / merge request / commit a todo refers to.
///
/// `iid` is the per-project number the app navigates by for issues and merge
/// requests; it is absent for targets that have no `iid` (e.g. a commit).
@freezed
abstract class TodoTarget with _$TodoTarget {
  const factory TodoTarget({int? id, int? iid, String? title, String? state}) =
      _TodoTarget;

  factory TodoTarget.fromJson(Map<String, dynamic> json) =>
      _$TodoTargetFromJson(json);
}
