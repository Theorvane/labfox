import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('Todo', () {
    final json = {
      'id': 102,
      'action_name': 'assigned',
      'target_type': 'Issue',
      'target_url': 'https://gitlab.com/g/p/-/issues/7',
      'body': 'Fix the login redirect',
      'state': 'pending',
      'created_at': '2026-08-18T10:00:00Z',
      'author': {'id': 9, 'username': 'octo', 'name': 'Octo'},
      'project': {'id': 42, 'name': 'p', 'path_with_namespace': 'g/p'},
      'target': {
        'id': 5001,
        'iid': 7,
        'title': 'Login redirect breaks',
        'state': 'opened',
      },
    };

    test('parses the fields the inbox shows', () {
      final todo = Todo.fromJson(json);

      expect(todo.id, 102);
      expect(todo.actionName, 'assigned');
      expect(todo.targetType, 'Issue');
      expect(todo.targetUrl, 'https://gitlab.com/g/p/-/issues/7');
      expect(todo.state, 'pending');
      expect(todo.isPending, isTrue);
      expect(todo.author?.username, 'octo');
      expect(todo.project?.pathWithNamespace, 'g/p');
      expect(todo.createdAt, DateTime.utc(2026, 8, 18, 10));
    });

    test('exposes the target iid so an issue or MR can be opened in-app', () {
      final todo = Todo.fromJson(json);

      expect(todo.target?.iid, 7);
      expect(todo.target?.title, 'Login redirect breaks');
    });

    test('prefers the target title, falling back to the body', () {
      expect(Todo.fromJson(json).title, 'Login redirect breaks');

      final noTarget = Map<String, dynamic>.from(json)..remove('target');
      expect(Todo.fromJson(noTarget).title, 'Fix the login redirect');
    });

    test('tolerates a group todo with no project', () {
      final groupTodo = Map<String, dynamic>.from(json)..remove('project');
      expect(Todo.fromJson(groupTodo).project, isNull);
    });

    test('distinguishes pending from done', () {
      final done = Map<String, dynamic>.from(json)..['state'] = 'done';
      expect(Todo.fromJson(done).isPending, isFalse);
    });
  });
}
