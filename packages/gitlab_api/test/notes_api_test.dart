import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  group('NotesApi.list', () {
    test('lists notes for an issue, oldest first', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          body: [
            {'id': 1, 'body': 'first', 'system': false},
            {'id': 2, 'body': 'second', 'system': false},
          ],
        );
      });

      final notes = await client.notes.list(
        NoteableType.issue,
        projectId: 42,
        iid: 5,
      );

      expect(captured.path, '/projects/42/issues/5/notes');
      expect(captured.queryParameters['sort'], 'asc');
      expect(notes.map((n) => n.body), ['first', 'second']);
    });

    test('uses the merge request path for an MR', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (status: 200, body: const []);
      });

      await client.notes.list(
        NoteableType.mergeRequest,
        projectId: 42,
        iid: 142,
      );

      expect(captured.path, '/projects/42/merge_requests/142/notes');
    });
  });

  group('NotesApi.create', () {
    test('posts a comment body and returns the created note', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (status: 201, body: {'id': 9, 'body': 'nice', 'system': false});
      });

      final note = await client.notes.create(
        NoteableType.issue,
        projectId: 42,
        iid: 5,
        body: 'nice',
      );

      expect(captured.method, 'POST');
      expect(captured.path, '/projects/42/issues/5/notes');
      expect(captured.data, {'body': 'nice'});
      expect(note.id, 9);
    });

    test('maps a 403 to a forbidden exception', () async {
      // A token without the api scope, or no permission to comment.
      final client = _client(
        (_) => (status: 403, body: const {'message': '403 Forbidden'}),
      );
      await expectLater(
        client.notes.create(
          NoteableType.issue,
          projectId: 1,
          iid: 1,
          body: 'x',
        ),
        throwsA(isA<GitLabForbiddenException>()),
      );
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
