import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('PipelinesApi.list', () {
    test('lists pipelines with pagination', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: {
            'x-next-page': ['2'],
          },
          body: [
            {'id': 944, 'status': 'failed', 'ref': 'main'},
          ],
        );
      });

      final page = await client.pipelines.list(42);

      expect(captured.path, '/projects/42/pipelines');
      expect(page.items.single.ciStatus, CiStatus.failed);
      expect(page.nextPage, 2);
    });
  });

  group('PipelinesApi.get', () {
    test('fetches one pipeline', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: const {},
          body: {'id': 944, 'status': 'success', 'ref': 'main'},
        );
      });

      final p = await client.pipelines.get(42, pipelineId: 944);

      expect(captured.path, '/projects/42/pipelines/944');
      expect(p.ciStatus, CiStatus.success);
    });

    test('maps a 404 to not found', () async {
      final client = _client(
        (_) => (status: 404, headers: const {}, body: const {}),
      );
      await expectLater(
        client.pipelines.get(1, pipelineId: 9),
        throwsA(isA<GitLabNotFoundException>()),
      );
    });
  });

  group('PipelinesApi.jobs', () {
    test('lists a pipeline\'s jobs', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: const {},
          body: [
            {'id': 1, 'name': 'compile', 'stage': 'build', 'status': 'success'},
            {'id': 2, 'name': 'unit-test', 'stage': 'test', 'status': 'failed'},
          ],
        );
      });

      final jobs = await client.pipelines.jobs(42, pipelineId: 944);

      expect(captured.path, '/projects/42/pipelines/944/jobs');
      expect(jobs.map((j) => j.name), ['compile', 'unit-test']);
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
