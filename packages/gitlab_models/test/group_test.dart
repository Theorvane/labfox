import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('Group', () {
    test('parses a GitLab payload', () {
      final group = Group.fromJson(const {
        'id': 42,
        'name': 'YouthPick',
        'full_path': 'youthpick',
        'description': 'The team',
        'visibility': 'private',
        'avatar_url': 'https://gitlab.example.com/g.png',
        'web_url': 'https://gitlab.com/groups/youthpick',
      });

      expect(group.id, 42);
      expect(group.name, 'YouthPick');
      expect(group.fullPath, 'youthpick');
      expect(group.description, 'The team');
      expect(group.visibility, 'private');
      expect(group.webUrl, 'https://gitlab.com/groups/youthpick');
    });

    test('leaves optional fields null when GitLab omits them', () {
      final group = Group.fromJson(const {
        'id': 1,
        'name': 'g',
        'full_path': 'g',
      });

      expect(group.description, isNull);
      expect(group.avatarUrl, isNull);
      expect(group.webUrl, isNull);
    });
  });
}
