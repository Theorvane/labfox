import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:labfox/features/project_overview/data/project_overview_repository.dart';

void main() {
  test('loads the project and its README from the default branch', () async {
    final client = _client((options) {
      if (options.path == '/projects/1') {
        return (
          status: 200,
          body: {
            'id': 1,
            'name': 'backend',
            'path_with_namespace': 'a/backend',
            'default_branch': 'main',
          },
          raw: false,
        );
      }
      // README raw endpoint for the default branch.
      expect(options.path, '/projects/1/repository/files/README.md/raw');
      expect(options.queryParameters['ref'], 'main');
      return (status: 200, body: '# Backend', raw: true);
    });

    final overview = await ProjectOverviewRepository(client).load(1);

    expect(overview.project.name, 'backend');
    expect(overview.readme, '# Backend');
  });

  test(
    'returns a null README when the project has one but the file is absent',
    () async {
      final client = _client((options) {
        if (options.path == '/projects/1') {
          return (
            status: 200,
            body: {
              'id': 1,
              'name': 'x',
              'path_with_namespace': 'a/x',
              'default_branch': 'main',
            },
            raw: false,
          );
        }
        return (status: 404, body: const {}, raw: false);
      });

      final overview = await ProjectOverviewRepository(client).load(1);
      expect(overview.readme, isNull);
    },
  );

  test(
    'skips the README fetch for an empty repo with no default branch',
    () async {
      var readmeCalled = false;
      final client = _client((options) {
        if (options.path == '/projects/1') {
          return (
            status: 200,
            body: {'id': 1, 'name': 'empty', 'path_with_namespace': 'a/empty'},
            raw: false,
          );
        }
        readmeCalled = true;
        return (status: 200, body: 'x', raw: true);
      });

      final overview = await ProjectOverviewRepository(client).load(1);

      // No default branch means no ref to fetch a README from; don't call it.
      expect(readmeCalled, isFalse);
      expect(overview.readme, isNull);
    },
  );
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
