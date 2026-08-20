import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  group('RepositoryApi.tree', () {
    test('lists a directory on a ref, sorted folders-first', () async {
      late RequestOptions captured;
      final client = _client((options) {
        captured = options;
        return (
          status: 200,
          headers: {
            'x-next-page': [''],
          },
          body: [
            {
              'id': '1',
              'name': 'main.dart',
              'type': 'blob',
              'path': 'lib/main.dart',
            },
            {'id': '2', 'name': 'src', 'type': 'tree', 'path': 'lib/src'},
          ],
          raw: false,
        );
      });

      final page = await client.repository.tree(42, ref: 'main', path: 'lib');

      expect(captured.path, '/projects/42/repository/tree');
      expect(captured.queryParameters['ref'], 'main');
      expect(captured.queryParameters['path'], 'lib');
      // Folder first after the model's sort.
      expect(page.items.first.name, 'src');
      expect(page.items.last.name, 'main.dart');
    });

    test('maps a 404 to a not-found exception', () async {
      final client = _client(
        (_) => (status: 404, headers: const {}, body: const {}, raw: false),
      );
      await expectLater(
        client.repository.tree(1, ref: 'main'),
        throwsA(isA<GitLabNotFoundException>()),
      );
    });
  });

  group('RepositoryApi.fileText', () {
    test('URL-encodes the path and returns the raw text', () async {
      late RequestOptions captured;
      final client = _client((options) {
        captured = options;
        return (
          status: 200,
          headers: const {},
          body: 'final x = 1;\n',
          raw: true,
        );
      });

      final file = await client.repository.fileText(
        42,
        path: 'lib/main.dart',
        ref: 'main',
      );

      // The slash in the path is encoded so it stays one path segment.
      expect(
        captured.path,
        '/projects/42/repository/files/lib%2Fmain.dart/raw',
      );
      expect(captured.queryParameters['ref'], 'main');
      expect(file!.isBinary, isFalse);
      expect(file.text, 'final x = 1;\n');
    });

    test('flags a binary file instead of returning garbage text', () async {
      // A PNG header has a NUL byte; rendering it as text is meaningless.
      final bytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x00, 0x01]);
      final client = _client(
        (_) => (status: 200, headers: const {}, body: bytes, raw: true),
      );

      final file = await client.repository.fileText(
        1,
        path: 'logo.png',
        ref: 'main',
      );

      expect(file!.isBinary, isTrue);
      expect(file.text, isNull);
    });

    test('returns null when the file does not exist', () async {
      final client = _client(
        (_) => (status: 404, headers: const {}, body: const {}, raw: false),
      );
      expect(
        await client.repository.fileText(1, path: 'nope', ref: 'main'),
        isNull,
      );
    });
  });

  group('RepositoryApi.createBranch', () {
    test('POSTs branch and ref and returns the new branch', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 201,
          headers: const {},
          body: {'name': 'feat/x', 'default': false, 'protected': false},
          raw: false,
        );
      });

      final branch = await client.repository.createBranch(
        7,
        name: 'feat/x',
        ref: 'main',
      );

      expect(captured.method, 'POST');
      expect(captured.path, '/projects/7/repository/branches');
      expect(captured.queryParameters, {'branch': 'feat/x', 'ref': 'main'});
      expect(branch.name, 'feat/x');
    });
  });
}

GitLabClient _client(
  ({int status, Map<String, List<String>> headers, Object? body, bool raw})
  Function(RequestOptions)
  handler,
) {
  final dio = Dio(BaseOptions(validateStatus: (s) => s != null && s < 500));
  dio.httpClientAdapter = _Adapter(handler);
  return GitLabClient(
    baseUrl: 'https://gitlab.com',
    token: 'glpat-x',
    dio: dio,
  );
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);
  final ({
    int status,
    Map<String, List<String>> headers,
    Object? body,
    bool raw,
  })
  Function(RequestOptions)
  handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final r = handler(options);
    final List<int> bytes;
    if (r.body == null) {
      bytes = const [];
    } else if (r.raw && r.body is Uint8List) {
      bytes = r.body as Uint8List;
    } else if (r.raw) {
      bytes = utf8.encode(r.body as String);
    } else {
      bytes = utf8.encode(json.encode(r.body));
    }
    return ResponseBody.fromBytes(
      Uint8List.fromList(bytes),
      r.status,
      headers: {
        Headers.contentTypeHeader: [
          r.raw ? 'application/octet-stream' : Headers.jsonContentType,
        ],
        ...r.headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
