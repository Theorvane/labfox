import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/app/router.dart';

void main() {
  group('Routes ref encoding', () {
    test('encodes a branch name with a slash in the tree route', () {
      // A branch like feature/foo has a slash; it must not split the query.
      final url = Routes.repository(1, 'feature/foo');
      expect(url, contains('ref=feature%2Ffoo'));
      expect(url, isNot(contains('ref=feature/foo')));
    });

    test('encodes ref and path together in a nested tree route', () {
      final url = Routes.repositoryPath(1, 'release/1.0', 'src/main.dart');
      expect(url, contains('ref=release%2F1.0'));
      expect(url, contains('path=src%2Fmain.dart'));
    });

    test('encodes ref and path in the file route', () {
      final url = Routes.file(1, 'feature/x', 'a b.txt');
      expect(url, contains('ref=feature%2Fx'));
      // A space in a filename must be encoded, not left raw.
      expect(url, isNot(contains('a b.txt')));
    });
  });
}
