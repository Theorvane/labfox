import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  group('SearchApi.projects', () {
    test('queries the projects scope with pagination', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: {
            'x-next-page': ['2'],
          },
          body: [
            {'id': 7, 'name': 'labfox', 'path_with_namespace': 'g/labfox'},
          ],
        );
      });

      final page = await client.search.projects('lab');

      expect(captured.path, '/search');
      expect(captured.queryParameters['scope'], 'projects');
      expect(captured.queryParameters['search'], 'lab');
      expect(page.items.single.name, 'labfox');
      expect(page.nextPage, 2);
    });
  });

  group('SearchApi.issues', () {
    test('queries the issues scope and keeps project_id', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: const {},
          body: [
            {
              'id': 1,
              'iid': 5,
              'title': 'bug',
              'state': 'opened',
              'project_id': 42,
            },
          ],
        );
      });

      final page = await client.search.issues('bug', page: 3);

      expect(captured.queryParameters['scope'], 'issues');
      expect(captured.queryParameters['page'], 3);
      expect(page.items.single.projectId, 42);
    });
  });

  group('SearchApi.mergeRequests', () {
    test('queries the merge_requests scope and keeps project_id', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: const {},
          body: [
            {
              'id': 1,
              'iid': 9,
              'title': 'mr',
              'state': 'opened',
              'source_branch': 'a',
              'target_branch': 'b',
              'project_id': 42,
            },
          ],
        );
      });

      final page = await client.search.mergeRequests('oauth');

      expect(captured.queryParameters['scope'], 'merge_requests');
      expect(page.items.single.projectId, 42);
    });

    test('maps a 403 to forbidden', () async {
      final client = _client(
        (_) => (status: 403, headers: const {}, body: const {}),
      );
      await expectLater(
        client.search.mergeRequests('x'),
        throwsA(isA<GitLabForbiddenException>()),
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
