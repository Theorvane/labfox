import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/notifications/todo_digest.dart';

Todo _todo(int id, String title, {String action = 'assigned'}) => Todo(
  id: id,
  state: 'pending',
  actionName: action,
  targetType: 'MergeRequest',
  body: title,
  target: TodoTarget(iid: id, title: title),
);

void main() {
  test('the first check announces nothing and only records what is there', () {
    final digest = digestTodos([_todo(1, 'a'), _todo(2, 'b')], null);

    // Enabling the setting must not fire a notification for every to-do the
    // user already knows about.
    expect(digest.entries, isEmpty);
    expect(digest.seenIds, {1, 2});
  });

  test('only unseen to-dos are announced', () {
    final digest = digestTodos([_todo(1, 'old'), _todo(2, 'new one')], {1});

    expect(digest.entries.single.body, contains('new one'));
    expect(digest.seenIds, {1, 2});
  });

  test('nothing new means nothing to show', () {
    final digest = digestTodos([_todo(1, 'a')], {1});
    expect(digest.entries, isEmpty);
  });

  test('a burst collapses into one summary instead of a stack', () {
    final digest = digestTodos([
      for (var i = 1; i <= 6; i++) _todo(i, 'item $i'),
    ], const {});

    expect(digest.entries, hasLength(1));
    expect(digest.entries.single.title, contains('6'));
  });

  test('cleared to-dos drop out so they can be announced again later', () {
    // The seen set tracks what is pending now, not everything ever seen, so it
    // cannot grow without bound.
    final digest = digestTodos([_todo(2, 'b')], {1, 2});
    expect(digest.seenIds, {2});
  });

  test('the reason leads the notification, the title follows', () {
    final digest = digestTodos([
      _todo(9, 'Add OAuth', action: 'build_failed'),
    ], const {});

    expect(digest.entries.single.title, isNotEmpty);
    expect(digest.entries.single.body, contains('Add OAuth'));
  });
}
