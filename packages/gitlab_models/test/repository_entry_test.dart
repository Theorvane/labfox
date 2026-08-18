import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('RepositoryEntry', () {
    test('parses a tree (folder) node', () {
      final entry = RepositoryEntry.fromJson(const {
        'id': 'a1b2',
        'name': 'src',
        'type': 'tree',
        'path': 'src',
      });

      expect(entry.name, 'src');
      expect(entry.path, 'src');
      expect(entry.isDirectory, isTrue);
      expect(entry.isFile, isFalse);
    });

    test('parses a blob (file) node', () {
      final entry = RepositoryEntry.fromJson(const {
        'id': 'c3d4',
        'name': 'main.dart',
        'type': 'blob',
        'path': 'lib/main.dart',
      });

      expect(entry.name, 'main.dart');
      expect(entry.path, 'lib/main.dart');
      expect(entry.isFile, isTrue);
      expect(entry.isDirectory, isFalse);
    });

    test('directories sort before files, then alphabetically', () {
      // GitHub-style ordering: folders first, so a reader scans structure before
      // contents.
      final entries = [
        RepositoryEntry.fromJson(const {
          'id': '1',
          'name': 'zeta.dart',
          'type': 'blob',
          'path': 'zeta.dart',
        }),
        RepositoryEntry.fromJson(const {
          'id': '2',
          'name': 'alpha',
          'type': 'tree',
          'path': 'alpha',
        }),
        RepositoryEntry.fromJson(const {
          'id': '3',
          'name': 'beta.dart',
          'type': 'blob',
          'path': 'beta.dart',
        }),
        RepositoryEntry.fromJson(const {
          'id': '4',
          'name': 'gamma',
          'type': 'tree',
          'path': 'gamma',
        }),
      ]..sort(RepositoryEntry.compare);

      expect(entries.map((e) => e.name).toList(), [
        'alpha',
        'gamma',
        'beta.dart',
        'zeta.dart',
      ]);
    });
  });
}
