import 'dart:convert';
import 'dart:typed_data';

import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  group('RepositoryFile.fromBytes', () {
    test('decodes UTF-8 text', () {
      final file = RepositoryFile.fromBytes(
        Uint8List.fromList(utf8.encode('héllo')),
      );
      expect(file.isBinary, isFalse);
      expect(file.text, isNotNull);
    });

    test('treats a NUL byte as binary', () {
      final file = RepositoryFile.fromBytes(
        Uint8List.fromList([0x41, 0x00, 0x42]),
      );
      expect(file.isBinary, isTrue);
      expect(file.text, isNull);
    });

    test('treats invalid UTF-8 as binary', () {
      // 0xFF is not valid UTF-8; a JPEG would trip this even without a NUL early.
      final file = RepositoryFile.fromBytes(
        Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]),
      );
      expect(file.isBinary, isTrue);
    });

    test('an empty file is text, not binary', () {
      final file = RepositoryFile.fromBytes(Uint8List(0));
      expect(file.isBinary, isFalse);
      expect(file.text, '');
    });
  });
}
