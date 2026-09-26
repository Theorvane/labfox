import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test('lists group milestones with pagination and group identity', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: {
          'x-next-page': ['2'],
        },
        body: [
          {
            'id': 12,
            'iid': 3,
            'group_id': 7,
            'title': '10.0',
            'state': 'active',
          },
        ],
      );
    });

    final page = await client.groupMilestones.list(
      'team/subgroup',
      state: 'active',
    );
    expect(request.path, '/groups/team%2Fsubgroup/milestones');
    expect(request.queryParameters['state'], 'active');
    expect(request.queryParameters['page'], 1);
    expect(page.nextPage, 2);
    expect(page.items.single.id, 12);
    expect(page.items.single.iid, 3);
    expect(page.items.single.groupId, 7);
  });

  test(
    'gets a group milestone by global ID and maps forbidden access',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 200,
          headers: <String, List<String>>{},
          body: {
            'id': 12,
            'iid': 3,
            'group_id': 7,
            'title': '10.0',
            'state': 'active',
          },
        );
      });
      final milestone = await client.groupMilestones.get(7, 12);
      expect(request.path, '/groups/7/milestones/12');
      expect(milestone.groupId, 7);

      final forbidden = _client(
        (_) => (status: 403, headers: const {}, body: const {}),
      );
      await expectLater(
        forbidden.groupMilestones.list(7),
        throwsA(isA<GitLabForbiddenException>()),
      );
    },
  );
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
    baseUrl: 'https://gitlab.example.com',
    token: 'glpat-xxxxxxxxxxxx',
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
