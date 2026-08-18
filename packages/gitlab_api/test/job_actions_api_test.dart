import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('JobsApi actions', () {
    test('retry posts and returns the updated job', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 201,
          body: {'id': 7001, 'name': 'unit', 'status': 'pending'},
        );
      });

      final job = await client.jobs.retry(42, jobId: 7001);

      expect(captured.method, 'POST');
      expect(captured.path, '/projects/42/jobs/7001/retry');
      expect(job.ciStatus, CiStatus.pending);
    });

    test('cancel posts to the cancel path', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 201,
          body: {'id': 7001, 'name': 'unit', 'status': 'canceled'},
        );
      });

      await client.jobs.cancel(42, jobId: 7001);
      expect(captured.path, '/projects/42/jobs/7001/cancel');
    });

    test('play posts to the play path for a manual job', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          body: {'id': 7001, 'name': 'deploy', 'status': 'pending'},
        );
      });

      await client.jobs.play(42, jobId: 7001);
      expect(captured.path, '/projects/42/jobs/7001/play');
    });

    test('a 403 maps to forbidden, a 409 to conflict', () async {
      final forbidden = _client((_) => (status: 403, body: const {}));
      await expectLater(
        forbidden.jobs.retry(1, jobId: 1),
        throwsA(isA<GitLabForbiddenException>()),
      );

      final conflict = _client(
        (_) => (status: 409, body: const {'message': 'not allowed'}),
      );
      await expectLater(
        conflict.jobs.cancel(1, jobId: 1),
        throwsA(isA<GitLabConflictException>()),
      );
    });
  });

  group('PipelinesApi actions', () {
    test('retry and cancel post to their paths', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (status: 201, body: {'id': 944, 'status': 'running'});
      });

      await client.pipelines.retry(42, pipelineId: 944);
      expect(captured.path, '/projects/42/pipelines/944/retry');

      await client.pipelines.cancel(42, pipelineId: 944);
      expect(captured.path, '/projects/42/pipelines/944/cancel');
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
