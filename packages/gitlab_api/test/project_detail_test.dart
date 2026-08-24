import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  group('ProjectsApi.get', () {
    test('fetches a single project by id', () async {
      late RequestOptions captured;
      final client = _client((options) {
        captured = options;
        return (
          status: 200,
          body: {
            'id': 42,
            'name': 'backend',
            'path_with_namespace': 'a/backend',
          },
          raw: false,
        );
      });

      final project = await client.projects.get(42);

      expect(captured.path, '/projects/42');
      expect(project.name, 'backend');
    });

    test('maps a 404 to a not-found exception', () async {
      final client = _client((_) => (status: 404, body: const {}, raw: false));
      await expectLater(
        client.projects.get(9),
        throwsA(isA<GitLabNotFoundException>()),
      );
    });
  });

  group('ProjectsApi.readme', () {
    test('returns the raw README text from the default branch', () async {
      late RequestOptions captured;
      final client = _client((options) {
        captured = options;
        return (status: 200, body: '# Title\n\nHello', raw: true);
      });

      final readme = await client.projects.readme(42, ref: 'main');

      // Raw file endpoint, path URL-encoded, ref passed as a query parameter.
      expect(captured.path, '/projects/42/repository/files/README.md/raw');
      expect(captured.queryParameters['ref'], 'main');
      expect(readme, '# Title\n\nHello');
    });

    test('returns null when the project has no README', () async {
      // A project without a README is normal — the overview shows without one,
      // it is not an error.
      final client = _client((_) => (status: 404, body: const {}, raw: false));
      expect(await client.projects.readme(42, ref: 'main'), isNull);
    });
  });
}

GitLabClient _client(
  ({int status, Object? body, bool raw}) Function(RequestOptions) handler,
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
  final ({int status, Object? body, bool raw}) Function(RequestOptions) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final r = handler(options);
    final payload = r.body == null
        ? ''
        : (r.raw ? r.body as String : json.encode(r.body));
    return ResponseBody.fromString(
      payload,
      r.status,
      headers: {
        Headers.contentTypeHeader: [
          r.raw ? 'text/plain' : Headers.jsonContentType,
        ],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
