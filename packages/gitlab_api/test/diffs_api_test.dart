import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  const fileEntry = {
    'old_path': 'lib/a.dart',
    'new_path': 'lib/a.dart',
    'diff': '@@ -1 +1 @@\n-a\n+b\n',
  };

  group('RepositoryApi.commitDiff', () {
    test('lists the files changed by a commit', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (status: 200, body: [fileEntry]);
      });

      final files = await client.repository.commitDiff(42, sha: 'abc123');

      expect(captured.path, '/projects/42/repository/commits/abc123/diff');
      // unidiff=true guarantees the unified-diff grammar the parser expects.
      expect(captured.queryParameters['unidiff'], true);
      expect(files.single.displayPath, 'lib/a.dart');
      expect(files.single.hunks, hasLength(1));
    });
  });

  group('MergeRequestsApi.diffs', () {
    test('lists the files changed by a merge request', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (status: 200, body: [fileEntry]);
      });

      final files = await client.mergeRequests.diffs(42, iid: 142);

      expect(captured.path, '/projects/42/merge_requests/142/diffs');
      expect(captured.queryParameters['unidiff'], true);
      expect(files.single.hunks, hasLength(1));
    });

    test('maps a 404 to not found', () async {
      final client = _client((_) => (status: 404, body: const {}));
      await expectLater(
        client.mergeRequests.diffs(1, iid: 9),
        throwsA(isA<GitLabNotFoundException>()),
      );
    });
  });
}

GitLabClient _client(
  ({int status, Object? body}) Function(RequestOptions) handler,
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
  final ({int status, Object? body}) Function(RequestOptions) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final r = handler(options);
    return ResponseBody.fromString(
      r.body == null ? '' : json.encode(r.body),
      r.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
