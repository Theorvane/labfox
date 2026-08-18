import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('Branch', () {
    test('parses a branch with its tip commit', () {
      final branch = Branch.fromJson(const {
        'name': 'main',
        'default': true,
        'protected': true,
        'commit': {
          'id': 'abc123def456',
          'short_id': 'abc123de',
          'title': 'Initial commit',
          'created_at': '2026-08-18T02:00:00.000Z',
        },
      });

      expect(branch.name, 'main');
      expect(branch.isDefault, isTrue);
      expect(branch.isProtected, isTrue);
      expect(branch.commit?.shortId, 'abc123de');
    });

    test('handles a branch payload without a commit', () {
      final branch = Branch.fromJson(const {
        'name': 'wip',
        'default': false,
        'protected': false,
      });
      expect(branch.name, 'wip');
      expect(branch.commit, isNull);
    });
  });
}
