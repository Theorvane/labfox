import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  group('GroupsApi.list', () {
    test('lists the groups visible to the user with pagination', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: {
            'x-next-page': ['2'],
          },
          body: [
            {'id': 42, 'name': 'YouthPick', 'full_path': 'youthpick'},
          ],
        );
      });

      final page = await client.groups.list();

      expect(captured.path, '/groups');
      // Membership only — all_available would list every public group on the
      // instance.
      expect(captured.queryParameters['all_available'], false);
      expect(captured.queryParameters['order_by'], 'name');
      expect(page.items.single.fullPath, 'youthpick');
      expect(page.nextPage, 2);
    });

    test('maps a 401 to unauthorized', () async {
      final client = _client(
        (_) => (status: 401, headers: const {}, body: const {}),
      );
      await expectLater(
        client.groups.list(),
        throwsA(isA<GitLabAuthException>()),
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
    final result = handler(options);
    return ResponseBody.fromString(
      jsonEncode(result.body),
      result.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...result.headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
