import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('JobsApi.get', () {
    test('fetches a single job by id', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          body: {
            'id': 7001,
            'name': 'unit-test',
            'stage': 'test',
            'status': 'failed',
          },
          raw: false,
        );
      });

      final job = await client.jobs.get(42, jobId: 7001);

      expect(captured.path, '/projects/42/jobs/7001');
      expect(job.ciStatus, CiStatus.failed);
    });
  });

  group('JobsApi.trace', () {
    test('returns the raw trace text', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          body:
              r'Running with gitlab-runner...'
              '\n'
              r'$ ./gradlew test',
          raw: true,
        );
      });

      final trace = await client.jobs.trace(42, jobId: 7001);

      expect(captured.path, '/projects/42/jobs/7001/trace');
      expect(trace, contains('gradlew test'));
    });

    test('returns empty string for a job with no trace yet', () async {
      final client = _client((_) => (status: 200, body: '', raw: true));
      expect(await client.jobs.trace(1, jobId: 1), '');
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
