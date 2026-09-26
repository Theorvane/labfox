import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Read-only project protected environments (Premium/Ultimate).
class ProtectedEnvironmentsApi {
  const ProtectedEnvironmentsApi(this._dio);

  final Dio _dio;

  String _path(Object projectId) =>
      '/projects/${Uri.encodeComponent(projectId.toString())}/protected_environments';

  Future<Paginated<ProtectedEnvironment>> list(
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
          context: 'listing protected environments',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(ProtectedEnvironment.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing protected environments');
    }
  }

  Future<ProtectedEnvironment> get(Object projectId, String name) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(name)}',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a protected environment',
        );
      }
      return ProtectedEnvironment.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a protected environment');
    }
  }
}
