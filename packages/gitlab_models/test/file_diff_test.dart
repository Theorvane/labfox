import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('FileDiff', () {
    test('parses a modified file', () {
      final fd = FileDiff.fromJson(const {
        'old_path': 'lib/a.dart',
        'new_path': 'lib/a.dart',
        'new_file': false,
        'renamed_file': false,
        'deleted_file': false,
        'diff': '@@ -1 +1 @@\n-a\n+b\n',
      });

      expect(fd.displayPath, 'lib/a.dart');
      expect(fd.isNew, isFalse);
      expect(fd.isRenamed, isFalse);
      expect(fd.hunks, hasLength(1));
    });

    test('shows old and new path for a rename', () {
      final fd = FileDiff.fromJson(const {
        'old_path': 'old.dart',
        'new_path': 'new.dart',
        'renamed_file': true,
        'diff': '',
      });
      expect(fd.isRenamed, isTrue);
      expect(fd.displayPath, 'old.dart → new.dart');
    });

    test('flags a new and a deleted file', () {
      final added = FileDiff.fromJson(const {
        'old_path': 'x',
        'new_path': 'x',
        'new_file': true,
        'diff': '',
      });
      final removed = FileDiff.fromJson(const {
        'old_path': 'x',
        'new_path': 'x',
        'deleted_file': true,
        'diff': '',
      });
      expect(added.isNew, isTrue);
      expect(removed.isDeleted, isTrue);
    });

    test('a file with no textual diff and no flags is treated as binary', () {
      final fd = FileDiff.fromJson(const {
        'old_path': 'logo.png',
        'new_path': 'logo.png',
        'diff': '',
      });
      expect(fd.isBinary, isTrue);
      expect(fd.hunks, isEmpty);
    });

    test('a too-large text file is flagged, not called binary', () {
      // GitLab omits the diff text and sets too_large; showing 'Binary file'
      // here would lie about a source file whose diff was simply truncated.
      final fd = FileDiff.fromJson(const {
        'old_path': 'lib/big.dart',
        'new_path': 'lib/big.dart',
        'diff': '',
        'too_large': true,
      });
      expect(fd.isTooLarge, isTrue);
      expect(fd.isBinary, isFalse);
    });

    test('a collapsed text file is flagged, not called binary', () {
      final fd = FileDiff.fromJson(const {
        'old_path': 'lib/x.dart',
        'new_path': 'lib/x.dart',
        'diff': '',
        'collapsed': true,
      });
      expect(fd.isCollapsed, isTrue);
      expect(fd.isBinary, isFalse);
    });
  });
}
