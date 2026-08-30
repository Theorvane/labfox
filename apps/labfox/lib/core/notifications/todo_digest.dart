import 'package:gitlab_models/gitlab_models.dart';

/// One notification a background check decided to post.
class TodoNotification {
  const TodoNotification({
    required this.id,
    required this.title,
    required this.body,
  });

  /// Stable per notification so a repeat of the same to-do replaces rather
  /// than stacks.
  final int id;
  final String title;
  final String body;
}

/// What a background check should announce, and what it should remember.
class TodoDigest {
  const TodoDigest({required this.entries, required this.seenIds});

  final List<TodoNotification> entries;

  /// Replaces the stored set. It tracks what is pending *now*, not everything
  /// ever seen, so it cannot grow without bound and a to-do cleared elsewhere
  /// stops being remembered.
  final Set<int> seenIds;
}

/// Beyond this many new items at once, one summary reads better than a stack
/// of notifications the user has to swipe away one by one.
const _summaryThreshold = 3;

/// Decides what to announce from the pending to-dos.
///
/// [alreadySeen] is null on the very first check: the user has just turned the
/// setting on, and every to-do they already know about would fire at once, so
/// the first pass only records. After that, anything unseen is news.
TodoDigest digestTodos(List<Todo> pending, Set<int>? alreadySeen) {
  final ids = pending.map((todo) => todo.id).toSet();
  if (alreadySeen == null) {
    return TodoDigest(entries: const [], seenIds: ids);
  }

  final fresh = pending
      .where((todo) => !alreadySeen.contains(todo.id))
      .toList(growable: false);
  if (fresh.isEmpty) {
    return TodoDigest(entries: const [], seenIds: ids);
  }

  if (fresh.length > _summaryThreshold) {
    return TodoDigest(
      entries: [
        TodoNotification(
          id: 0,
          title: '${fresh.length} new to-dos',
          body: 'Open LabFox to see what needs you.',
        ),
      ],
      seenIds: ids,
    );
  }

  return TodoDigest(
    entries: [
      for (final todo in fresh)
        TodoNotification(
          id: todo.id,
          // The reason leads: "why am I being told" is the useful half, and
          // the title alone does not say it.
          title: _reason(todo.actionName),
          body: todo.target?.title ?? todo.body ?? '',
        ),
    ],
    seenIds: ids,
  );
}

/// The to-do reason as a sentence. Deliberately not localized: the background
/// isolate has no BuildContext, and a localization delegate cannot be resolved
/// there without loading the whole app.
String _reason(String action) => switch (action) {
  'assigned' => 'Assigned to you',
  'mentioned' || 'directly_addressed' => 'You were mentioned',
  'build_failed' => 'Pipeline failed',
  'approval_required' => 'Review requested',
  'unmergeable' => 'Cannot be merged',
  'marked' => 'Marked for you',
  _ => 'New to-do',
};
