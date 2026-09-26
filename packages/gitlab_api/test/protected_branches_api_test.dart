import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test('lists protected branch rules and preserves access levels', () async {
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
            'id': 100,
            'name': 'main',
            'allow_force_push': false,
            'code_owner_approval_required': true,
            'inherited': true,
            'push_access_levels': [
              {
                'id': 1001,
                'access_level': 40,
                'access_level_description': 'Maintainers',
              },
            ],
            'merge_access_levels': [
              {
                'id': 2001,
                'access_level': null,
                'group_id': 1234,
                'access_level_description': 'Release team',
              },
            ],
          },
        ],
      );
    });

    final page = await client.protectedBranches.list('team/app');
    expect(request.path, '/projects/team%2Fapp/protected_branches');
    expect(request.queryParameters['page'], 1);
    expect(page.nextPage, 2);
    final branch = page.items.single;
    expect(branch.name, 'main');
    expect(branch.inherited, isTrue);
    expect(branch.codeOwnerApprovalRequired, isTrue);
    expect(branch.pushAccessLevels.single.accessLevel, 40);
    expect(branch.mergeAccessLevels.single.groupId, 1234);
  });

  test(
    'gets wildcard rule by encoded name and maps forbidden access',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 200,
          headers: <String, List<String>>{},
          body: {
            'id': 101,
            'name': 'release/*',
            'push_access_levels': [],
            'merge_access_levels': [],
          },
        );
      });
      final rule = await client.protectedBranches.get(7, 'release/*');
      expect(request.path, '/projects/7/protected_branches/release%2F*');
      expect(rule.name, 'release/*');

      final forbidden = _client(
        (_) => (status: 403, headers: const {}, body: const {}),
      );
      await expectLater(
        forbidden.protectedBranches.list(7),
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
