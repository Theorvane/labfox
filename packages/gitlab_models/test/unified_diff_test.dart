import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('parseUnifiedDiff', () {
    test('parses a hunk header into ranges', () {
      final hunks = parseUnifiedDiff('@@ -1,3 +1,4 @@\n a\n-b\n+c\n+d\n e\n');
      expect(hunks, hasLength(1));
      expect(hunks.single.oldStart, 1);
      expect(hunks.single.newStart, 1);
    });

    test('classifies context, added, and removed lines', () {
      final hunks = parseUnifiedDiff('@@ -1,2 +1,2 @@\n context\n-old\n+new\n');
      final lines = hunks.single.lines;

      expect(lines[0].type, DiffLineType.context);
      expect(lines[0].text, 'context');
      expect(lines[1].type, DiffLineType.removed);
      expect(lines[1].text, 'old');
      expect(lines[2].type, DiffLineType.added);
      expect(lines[2].text, 'new');
    });

    test('tracks old and new line numbers', () {
      // context at 1/1, removed old line 2, added new line 2, context 3/3.
      final hunks = parseUnifiedDiff('@@ -1,3 +1,3 @@\n a\n-b\n+c\n d\n');
      final lines = hunks.single.lines;

      expect((lines[0].oldLine, lines[0].newLine), (1, 1));
      expect(
        (lines[1].oldLine, lines[1].newLine),
        (2, null),
      ); // removed: no new line
      expect(
        (lines[2].oldLine, lines[2].newLine),
        (null, 2),
      ); // added: no old line
      expect((lines[3].oldLine, lines[3].newLine), (3, 3));
    });

    test('handles multiple hunks', () {
      final hunks = parseUnifiedDiff(
        '@@ -1,1 +1,1 @@\n-a\n+b\n@@ -10,1 +10,1 @@\n-x\n+y\n',
      );
      expect(hunks, hasLength(2));
      expect(hunks[1].oldStart, 10);
    });

    test('ignores the no-newline marker', () {
      final hunks = parseUnifiedDiff(
        '@@ -1 +1 @@\n-a\n+b\n\\ No newline at end of file\n',
      );
      // The backslash marker is metadata, not a content line.
      expect(
        hunks.single.lines.where((l) => l.text.startsWith('No newline')),
        isEmpty,
      );
    });

    test('returns empty for empty input', () {
      expect(parseUnifiedDiff(''), isEmpty);
    });
  });
}
