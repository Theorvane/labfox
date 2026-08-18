import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('Project', () {
    test('parses a full GitLab payload', () {
      final project = Project.fromJson(const {
        'id': 278964,
        'name': 'backend',
        'path_with_namespace': 'youthpick/backend',
        'description': 'The backend service',
        'star_count': 12,
        'visibility': 'private',
        'last_activity_at': '2026-08-18T02:00:00.000Z',
        'avatar_url': 'https://gitlab.example.com/avatar.png',
      });

      expect(project.id, 278964);
      expect(project.name, 'backend');
      expect(project.pathWithNamespace, 'youthpick/backend');
      expect(project.starCount, 12);
      expect(project.visibility, 'private');
      expect(project.lastActivityAt, DateTime.utc(2026, 8, 18, 2));
    });

    test('leaves optional fields null when GitLab omits them', () {
      // A minimal project payload — no description, no avatar. These must read
      // as absent, not as empty strings.
      final project = Project.fromJson(const {
        'id': 1,
        'name': 'scratch',
        'path_with_namespace': 'me/scratch',
      });

      expect(project.description, isNull);
      expect(project.avatarUrl, isNull);
      expect(project.lastActivityAt, isNull);
      // star_count is absent in this payload; default to zero, not null, since
      // the UI always shows a count.
      expect(project.starCount, 0);
    });

    test('ignores fields LabFox does not model', () {
      final project = Project.fromJson(const {
        'id': 1,
        'name': 'scratch',
        'path_with_namespace': 'me/scratch',
        'some_future_field': 'value',
      });

      expect(project.id, 1);
    });

    test('namespace is the path without the project name', () {
      const project = Project(
        id: 1,
        name: 'backend',
        pathWithNamespace: 'youthpick/backend',
      );

      expect(project.namespace, 'youthpick');
    });

    test('namespace handles nested groups', () {
      const project = Project(
        id: 1,
        name: 'api',
        pathWithNamespace: 'org/team/api',
      );

      expect(project.namespace, 'org/team');
    });
  });
}
