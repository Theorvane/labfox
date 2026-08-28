import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Group endpoints.
class GroupsApi {
  const GroupsApi(this._dio);

  final Dio _dio;

  /// Lists groups the current user can access.
  Future<Paginated<Group>> list({int page = 1, int perPage = 20}) async {
    try {
      final response = await _dio.get<dynamic>(
        '/groups',
        queryParameters: {
          'all_available': false,
          'order_by': 'name',
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading groups',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(Group.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'loading groups');
    }
  }
}
