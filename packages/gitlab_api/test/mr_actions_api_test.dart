import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  group('MergeRequestsApi.approve / unapprove', () {
    test('approve posts to the approve path', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (status: 201, body: const {});
      });

      await client.mergeRequests.approve(42, iid: 142);

      expect(captured.method, 'POST');
      expect(captured.path, '/projects/42/merge_requests/142/approve');
    });

    test('unapprove posts to the unapprove path', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (status: 201, body: const {});
      });

      await client.mergeRequests.unapprove(42, iid: 142);

      expect(captured.path, '/projects/42/merge_requests/142/unapprove');
    });

    test('approve maps a 403 to forbidden', () async {
      final client = _client((_) => (status: 403, body: const {}));
      await expectLater(
        client.mergeRequests.approve(1, iid: 1),
        throwsA(isA<GitLabForbiddenException>()),
      );
    });
  });

  group('MergeRequestsApi.approvals', () {
    test('fetches the approval state', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          body: {
            'approvals_required': 1,
            'user_has_approved': false,
            'approved_by': [],
          },
        );
      });

      final a = await client.mergeRequests.approvals(42, iid: 142);

      expect(captured.path, '/projects/42/merge_requests/142/approvals');
      expect(a.approvalsRequired, 1);
    });
  });

  group('MergeRequestsApi.merge', () {
    test('PUTs the merge and returns the merged MR', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          body: {
            'id': 1,
            'iid': 142,
            'title': 'x',
            'state': 'merged',
            'source_branch': 'a',
            'target_branch': 'b',
          },
        );
      });

      final mr = await client.mergeRequests.merge(42, iid: 142);

      expect(captured.method, 'PUT');
      expect(captured.path, '/projects/42/merge_requests/142/merge');
      // A plain merge does not ask GitLab to squash.
      expect(captured.queryParameters.containsKey('squash'), isFalse);
      expect(mr.isMerged, isTrue);
    });

    test('passes squash=true when squashing', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          body: {
            'id': 1,
            'iid': 142,
            'title': 'x',
            'state': 'merged',
            'source_branch': 'a',
            'target_branch': 'b',
          },
        );
      });

      await client.mergeRequests.merge(42, iid: 142, squash: true);

      expect(captured.queryParameters['squash'], true);
    });

    test(
      'maps a 405 to a not-mergeable exception, distinct from a 403',
      () async {
        final notMergeable = _client(
          (_) => (status: 405, body: const {'message': 'Method Not Allowed'}),
        );
        await expectLater(
          notMergeable.mergeRequests.merge(1, iid: 1),
          throwsA(isA<GitLabNotMergeableException>()),
        );

        final forbidden = _client((_) => (status: 403, body: const {}));
        await expectLater(
          forbidden.mergeRequests.merge(1, iid: 1),
          throwsA(isA<GitLabForbiddenException>()),
        );
      },
    );
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
