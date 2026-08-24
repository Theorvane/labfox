import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:labfox/features/projects/data/projects_repository.dart';

void main() {
  test('returns the projects from the first page', () async {
    final client = GitLabClient(
      baseUrl: 'https://gitlab.com',
      token: 'glpat-x',
      dio: _fakeDio(
        (_) => (
          status: 200,
          body: [
            {'id': 1, 'name': 'backend', 'path_with_namespace': 'a/backend'},
          ],
        ),
      ),
    );
    final repo = ProjectsRepository(client);

    final projects = await repo.list();

    expect(projects, hasLength(1));
    expect(projects.single.name, 'backend');
  });

  test('propagates a domain exception on failure', () async {
    final client = GitLabClient(
      baseUrl: 'https://gitlab.com',
      token: 'bad',
      dio: _fakeDio((_) => (status: 401, body: const {})),
    );
    final repo = ProjectsRepository(client);

    await expectLater(repo.list(), throwsA(isA<GitLabAuthException>()));
  });
}

Dio _fakeDio(({int status, Object? body}) Function(RequestOptions) handler) {
  final dio = Dio(BaseOptions(validateStatus: (s) => s != null && s < 500));
  dio.httpClientAdapter = _FakeAdapter(handler);
  return dio;
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);
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
