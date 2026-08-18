import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  group('TodosApi.list', () {
    test('lists pending todos by default with pagination', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: {
            'x-next-page': ['2'],
          },
          body: [
            {
              'id': 1,
              'action_name': 'assigned',
              'target_type': 'MergeRequest',
              'state': 'pending',
            },
          ],
        );
      });

      final page = await client.todos.list();

      expect(captured.path, '/todos');
      expect(captured.queryParameters['state'], 'pending');
      expect(page.items.single.id, 1);
      expect(page.nextPage, 2);
    });

    test('passes the done state filter through', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (status: 200, headers: const {}, body: const []);
      });

      await client.todos.list(state: TodoState.done);

      expect(captured.queryParameters['state'], 'done');
    });

    test('maps a 401 to unauthorized', () async {
      final client = _client(
        (_) => (status: 401, headers: const {}, body: const {}),
      );
      await expectLater(
        client.todos.list(),
        throwsA(isA<GitLabAuthException>()),
      );
    });
  });

  group('TodosApi.markDone', () {
    test('posts to the single-todo done path', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (status: 200, headers: const {}, body: const {});
      });

      await client.todos.markDone(102);

      expect(captured.method, 'POST');
      expect(captured.path, '/todos/102/mark_as_done');
    });
  });

  group('TodosApi.markAllDone', () {
    test('posts to the mark-all path', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (status: 204, headers: const {}, body: null);
      });

      await client.todos.markAllDone();

      expect(captured.method, 'POST');
      expect(captured.path, '/todos/mark_as_done');
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
