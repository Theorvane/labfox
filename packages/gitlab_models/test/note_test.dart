import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('Note', () {
    test('parses a user comment', () {
      final note = Note.fromJson(const {
        'id': 301,
        'body': 'Looks good to me.',
        'system': false,
        'created_at': '2026-08-18T02:00:00.000Z',
        'author': {'id': 7, 'username': 'jungwon', 'name': 'Jungwon'},
      });

      expect(note.id, 301);
      expect(note.body, 'Looks good to me.');
      expect(note.isSystem, isFalse);
      expect(note.author?.username, 'jungwon');
      expect(note.createdAt, DateTime.utc(2026, 8, 18, 2));
    });

    test('flags a system note', () {
      // "changed the milestone" and similar are system-generated noise in a
      // comment thread.
      final note = Note.fromJson(const {
        'id': 1,
        'body': 'changed milestone to %Sprint 1',
        'system': true,
      });
      expect(note.isSystem, isTrue);
    });

    test('defaults system to false when absent', () {
      final note = Note.fromJson(const {'id': 1, 'body': 'hi'});
      expect(note.isSystem, isFalse);
    });
  });
}
