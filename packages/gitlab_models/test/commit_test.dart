import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('Commit', () {
    test('parses a full commit payload', () {
      final commit = Commit.fromJson(const {
        'id': 'abc123def456789',
        'short_id': 'abc123de',
        'title': 'feat: add sign-in',
        'message': 'feat: add sign-in\n\nBody here.',
        'author_name': 'Jungwon',
        'authored_date': '2026-08-18T02:00:00.000Z',
      });

      expect(commit.id, 'abc123def456789');
      expect(commit.shortId, 'abc123de');
      expect(commit.title, 'feat: add sign-in');
      expect(commit.authorName, 'Jungwon');
      expect(commit.authoredDate, DateTime.utc(2026, 8, 18, 2));
    });

    test('falls back to the leading id chars when short_id is absent', () {
      // Some endpoints omit short_id; the UI still needs a short handle.
      final commit = Commit.fromJson(const {
        'id': 'abcdef0123456789',
        'title': 'x',
      });
      expect(commit.shortId, 'abcdef01');
    });

    test('parses commit stats when present', () {
      final commit = Commit.fromJson(const {
        'id': 'a',
        'title': 'x',
        'stats': {'additions': 10, 'deletions': 3, 'total': 13},
      });
      expect(commit.stats?.additions, 10);
      expect(commit.stats?.deletions, 3);
    });
  });
}
