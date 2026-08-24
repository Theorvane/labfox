import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  group('GitLabClient 401 refresh-and-retry', () {
    test('refreshes once and retries the request with the new token', () async {
      var refreshCalls = 0;
      final adapter = _Adapter();
      final client = GitLabClient(
        baseUrl: 'https://gitlab.com',
        token: 'stale',
        bearer: true,
        onUnauthorized: () async {
          refreshCalls++;
          return 'fresh';
        },
        dio: _dio(adapter),
      );

      final user = await client.users.current();

      expect(user.username, 'jungwon');
      expect(refreshCalls, 1);
      // The first attempt used the stale token and 401'd; the retry used the
      // refreshed one.
      expect(adapter.seenTokens, ['Bearer stale', 'Bearer fresh']);
    });

    test('surfaces the 401 when the refresh yields nothing', () async {
      final client = GitLabClient(
        baseUrl: 'https://gitlab.com',
        token: 'stale',
        bearer: true,
        onUnauthorized: () async => null,
        dio: _dio(_Adapter()),
      );

      await expectLater(
        client.users.current(),
        throwsA(isA<GitLabAuthException>()),
      );
    });

    test('does not retry without a refresh hook', () async {
      final adapter = _Adapter();
      final client = GitLabClient(
        baseUrl: 'https://gitlab.com',
        token: 'stale',
        bearer: true,
        dio: _dio(adapter),
      );

      await expectLater(
        client.users.current(),
        throwsA(isA<GitLabAuthException>()),
      );
      // Only the first attempt was made; nothing retried.
      expect(adapter.seenTokens, ['Bearer stale']);
    });

    test('refreshes once for concurrent requests, not once each', () async {
      var refreshCalls = 0;
      final client = GitLabClient(
        baseUrl: 'https://gitlab.com',
        token: 'stale',
        bearer: true,
        onUnauthorized: () async {
          refreshCalls++;
          return 'fresh';
        },
        dio: _dio(_Adapter()),
      );

      await Future.wait([
        client.users.current(),
        client.users.current(),
        client.users.current(),
      ]);

      expect(refreshCalls, 1);
    });
  });
}

Dio _dio(HttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(validateStatus: (s) => s != null && s < 500));
  dio.httpClientAdapter = adapter;
  return dio;
}

/// Rejects the stale token with 401 and accepts anything else with the user.
class _Adapter implements HttpClientAdapter {
  final List<String?> seenTokens = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final auth = options.headers['Authorization'] as String?;
    seenTokens.add(auth);
    if (auth == 'Bearer stale') {
      return ResponseBody.fromString(
        json.encode({'message': '401 Unauthorized'}),
        401,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(
      json.encode({'id': 1, 'username': 'jungwon', 'name': 'Jungwon'}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
