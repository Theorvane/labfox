import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  group('ProjectsApi.list', () {
    test('requests membership projects and parses them', () async {
      late RequestOptions captured;
      final client = GitLabClient(
        baseUrl: 'https://gitlab.com',
        token: 'glpat-x',
        dio: _fakeDio((options) {
          captured = options;
          return (
            status: 200,
            headers: {
              'x-next-page': ['2'],
            },
            body: [
              {'id': 1, 'name': 'backend', 'path_with_namespace': 'a/backend'},
              {'id': 2, 'name': 'web', 'path_with_namespace': 'a/web'},
            ],
          );
        }),
      );

      final page = await client.projects.list();

      // Default list is the member's own projects, most recently active first.
      expect(captured.path, '/projects');
      expect(captured.queryParameters['membership'], true);
      expect(captured.queryParameters['order_by'], 'last_activity_at');
      expect(page.items, hasLength(2));
      expect(page.items.first.name, 'backend');
      expect(page.nextPage, 2);
    });

    test('passes the page cursor through', () async {
      late RequestOptions captured;
      final client = GitLabClient(
        baseUrl: 'https://gitlab.com',
        token: 'glpat-x',
        dio: _fakeDio((options) {
          captured = options;
          return (status: 200, headers: const {}, body: const []);
        }),
      );

      await client.projects.list(page: 3);

      expect(captured.queryParameters['page'], 3);
      // A last page reports no next cursor.
      final page = await client.projects.list(page: 3);
      expect(page.hasMore, isFalse);
    });

    test('maps a 401 to an auth exception', () async {
      final client = GitLabClient(
        baseUrl: 'https://gitlab.com',
        token: 'bad',
        dio: _fakeDio((_) => (status: 401, headers: const {}, body: const {})),
      );

      await expectLater(
        client.projects.list(),
        throwsA(isA<GitLabAuthException>()),
      );
    });
  });
}

Dio _fakeDio(
  ({int status, Map<String, List<String>> headers, Object? body}) Function(
    RequestOptions,
  )
  handler,
) {
  final dio = Dio(BaseOptions(validateStatus: (s) => s != null && s < 500));
  dio.httpClientAdapter = _FakeAdapter(handler);
  return dio;
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);
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
