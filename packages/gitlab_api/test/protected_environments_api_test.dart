import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test(
    'lists protected environments and parses deployment approval rules',
    () async {
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
              'name': 'production',
              'required_approval_count': 2,
              'deploy_access_levels': [
                {
                  'id': 12,
                  'access_level': 40,
                  'access_level_description': 'Maintainers',
                },
              ],
              'approval_rules': [
                {
                  'id': 38,
                  'group_id': 134,
                  'access_level_description': 'Release team',
                  'required_approvals': 2,
                },
              ],
            },
          ],
        );
      });

      final page = await client.protectedEnvironments.list('team/app');
      expect(request.path, '/projects/team%2Fapp/protected_environments');
      expect(request.queryParameters['page'], 1);
      expect(page.nextPage, 2);
      final environment = page.items.single;
      expect(environment.name, 'production');
      expect(environment.requiredApprovalCount, 2);
      expect(environment.deployAccessLevels.single.description, 'Maintainers');
      expect(environment.approvalRules.single.requiredApprovals, 2);
      expect(environment.approvalRules.single.groupId, 134);
    },
  );

  test('gets an encoded environment name and maps forbidden access', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: <String, List<String>>{},
        body: {'name': 'review/production', 'deploy_access_levels': []},
      );
    });
    final environment = await client.protectedEnvironments.get(
      7,
      'review/production',
    );
    expect(
      request.path,
      '/projects/7/protected_environments/review%2Fproduction',
    );
    expect(environment.name, 'review/production');
    expect(environment.approvalRules, isEmpty);

    final forbidden = _client(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    await expectLater(
      forbidden.protectedEnvironments.list(7),
      throwsA(isA<GitLabForbiddenException>()),
    );
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
