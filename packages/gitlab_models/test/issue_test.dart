import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('Issue', () {
    test('keeps iid and id distinct', () {
      // The number a user sees (#282) is the iid; id is the global identifier.
      // Flattening them would route to the wrong resource.
      final issue = Issue.fromJson(const {
        'id': 99401,
        'iid': 282,
        'title': 'Android login error',
        'state': 'opened',
      });

      expect(issue.id, 99401);
      expect(issue.iid, 282);
      expect(issue.id, isNot(issue.iid));
    });

    test('parses state, author, and description', () {
      final issue = Issue.fromJson(const {
        'id': 1,
        'iid': 5,
        'title': 'Cache optimization',
        'state': 'closed',
        'description': 'Use Redis.',
        'author': {'id': 7, 'username': 'jungwon', 'name': 'Jungwon'},
      });

      expect(issue.isOpen, isFalse);
      expect(issue.state, 'closed');
      expect(issue.description, 'Use Redis.');
      expect(issue.author?.username, 'jungwon');
    });

    test('isOpen is true for the opened state', () {
      final issue = Issue.fromJson(const {
        'id': 1,
        'iid': 1,
        'title': 'x',
        'state': 'opened',
      });
      expect(issue.isOpen, isTrue);
    });

    test('parses labels with their colours', () {
      final issue = Issue.fromJson(const {
        'id': 1,
        'iid': 1,
        'title': 'x',
        'state': 'opened',
        'labels': ['bug', 'android'],
      });
      expect(issue.labels, ['bug', 'android']);
    });

    test('defaults labels to empty when absent', () {
      final issue = Issue.fromJson(const {
        'id': 1,
        'iid': 1,
        'title': 'x',
        'state': 'opened',
      });
      expect(issue.labels, isEmpty);
    });
  });
}
