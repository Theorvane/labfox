import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Read-only protected tag rules for one project.
class ProtectedTagsApi {
  const ProtectedTagsApi(this._dio);

  final Dio _dio;

  String _path(Object projectId) =>
      '/projects/${Uri.encodeComponent(projectId.toString())}/protected_tags';

  Future<Paginated<ProtectedTag>> list(
    Object projectId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(projectId),
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing protected tags',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(ProtectedTag.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing protected tags');
    }
  }

  Future<ProtectedTag> get(Object projectId, String name) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(name)}',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a protected tag',
        );
      }
      return ProtectedTag.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a protected tag');
    }
  }
}
