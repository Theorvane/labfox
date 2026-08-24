import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  group('RepositoryApi.branches', () {
    test('lists branches', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: {
            'x-next-page': [''],
          },
          body: [
            {'name': 'main', 'default': true, 'protected': true},
            {'name': 'dev', 'default': false, 'protected': false},
          ],
        );
      });

      final page = await client.repository.branches(42);

      expect(captured.path, '/projects/42/repository/branches');
      expect(page.items.map((b) => b.name), ['main', 'dev']);
    });
  });

  group('RepositoryApi.commits', () {
    test('lists commits on a ref', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: {
            'x-next-page': ['2'],
          },
          body: [
            {'id': 'a1', 'short_id': 'a1', 'title': 'first'},
          ],
        );
      });

      final page = await client.repository.commits(42, ref: 'main');

      expect(captured.path, '/projects/42/repository/commits');
      expect(captured.queryParameters['ref_name'], 'main');
      expect(page.items.single.title, 'first');
      expect(page.nextPage, 2);
    });
  });

  group('RepositoryApi.commit', () {
    test('fetches one commit with stats', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: const {},
          body: {
            'id': 'abc123',
            'title': 'x',
            'stats': {'additions': 5, 'deletions': 2, 'total': 7},
          },
        );
      });

      final commit = await client.repository.commit(42, sha: 'abc123');

      expect(captured.path, '/projects/42/repository/commits/abc123');
      expect(commit.stats?.additions, 5);
    });

    test('maps a 404 to not found', () async {
      final client = _client(
        (_) => (status: 404, headers: const {}, body: const {}),
      );
      await expectLater(
        client.repository.commit(1, sha: 'deadbeef'),
        throwsA(isA<GitLabNotFoundException>()),
      );
    });
  });
}

GitLabClient _client(
  ({int status, Map<String, List<String>> headers, Object? body}) Function(
    RequestOptions,
  )
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
  final ({int status, Map<String, List<String>> headers, Object? body})
  Function(RequestOptions)
  handler;

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
        ...r.headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
