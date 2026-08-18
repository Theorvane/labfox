import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';
import 'repository_file.dart';

/// Repository tree and file endpoints.
class RepositoryApi {
  const RepositoryApi(this._dio);

  final Dio _dio;

  /// Lists a directory of the tree on a ref.
  ///
  /// [path] is a directory path, empty for the root. Results are sorted
  /// folders-first. Pagination is by page number; the next cursor comes from
  /// the response headers.
  Future<Paginated<RepositoryEntry>> tree(
    Object projectId, {
    required String ref,
    String path = '',
    int page = 1,
    int perPage = 100,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/repository/tree',
        queryParameters: {
          'ref': ref,
          if (path.isNotEmpty) 'path': path,
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing the tree',
        );
      }
      final entries =
          (response.data as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>()
              .map(RepositoryEntry.fromJson)
              .toList()
            ..sort(RepositoryEntry.compare);
      return Paginated.fromHeaders(entries, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing the tree');
    }
  }

  /// The contents of a file on a ref, or null when it does not exist.
  Future<RepositoryFile?> fileText(
    Object projectId, {
    required String path,
    required String ref,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        // The whole path is one URL segment, so its slashes are encoded.
        '/projects/${_enc(projectId)}/repository/files/${Uri.encodeComponent(path)}/raw',
        queryParameters: {'ref': ref},
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 404) {
        return null;
      }
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'reading the file',
        );
      }
      final bytes = Uint8List.fromList(response.data ?? const []);
      return RepositoryFile.fromBytes(bytes);
    } on DioException catch (error) {
      throw mapError(error, context: 'reading the file');
    }
  }

  /// Encodes a project id: numeric ids pass through, `group/project` paths are
  /// URL-encoded.
  static String _enc(Object projectId) =>
      projectId is int ? '$projectId' : Uri.encodeComponent('$projectId');
}
