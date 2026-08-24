import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../gitlab_client.dart';

/// What a note is attached to. Issues and merge requests use different paths.
enum NoteableType {
  issue('issues'),
  mergeRequest('merge_requests');

  const NoteableType(this.segment);

  /// The path segment: `issues` or `merge_requests`.
  final String segment;
}

/// Comment (note) endpoints for issues and merge requests.
class NotesApi {
  const NotesApi(this._dio);

  final Dio _dio;

  /// Lists the notes on an issue or merge request, oldest first.
  Future<List<Note>> list(
    NoteableType type, {
    required Object projectId,
    required int iid,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(type, projectId, iid),
        queryParameters: {'sort': 'asc', 'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading comments',
        );
      }
      return (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Note.fromJson)
          .toList(growable: false);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading comments');
    }
  }

  /// Posts a comment and returns the created note.
  ///
  /// The body is a secret only in the sense that it is user content — it is
  /// never logged. A 403 means the token cannot comment here.
  Future<Note> create(
    NoteableType type, {
    required Object projectId,
    required int iid,
    required String body,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _path(type, projectId, iid),
        data: {'body': body},
      );
      final data = response.data;
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'posting a comment',
        );
      }
      return Note.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'posting a comment');
    }
  }

  String _path(NoteableType type, Object projectId, int iid) {
    final id = projectId is int
        ? '$projectId'
        : Uri.encodeComponent('$projectId');
    return '/projects/$id/${type.segment}/$iid/notes';
  }
}
