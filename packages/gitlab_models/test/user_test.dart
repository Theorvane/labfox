import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('User', () {
    test('parses a full payload', () {
      final user = User.fromJson(const {
        'id': 42,
        'username': 'jungwon',
        'name': 'Jungwon',
        'avatar_url': 'https://gitlab.example.com/avatar.png',
        'web_url': 'https://gitlab.example.com/jungwon',
        'state': 'active',
      });

      expect(user.id, 42);
      expect(user.username, 'jungwon');
      expect(user.avatarUrl, 'https://gitlab.example.com/avatar.png');
    });

    test('leaves optional fields null when GitLab omits them', () {
      // A token without the read_user scope gets a reduced payload; that must
      // not be mistaken for a user with an empty avatar.
      final user = User.fromJson(const {
        'id': 7,
        'username': 'minsu',
        'name': 'Minsu',
      });

      expect(user.avatarUrl, isNull);
      expect(user.webUrl, isNull);
      expect(user.state, isNull);
    });

    test('ignores fields LabFox does not model', () {
      // GitLab adds response fields without warning; parsing must not break.
      final user = User.fromJson(const {
        'id': 1,
        'username': 'root',
        'name': 'Administrator',
        'some_future_field': 'value',
      });

      expect(user.id, 1);
    });
  });
}
