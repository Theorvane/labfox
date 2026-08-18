import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Project endpoints.
class ProjectsApi {
  const ProjectsApi(this._dio);

  final Dio _dio;

  /// The projects the current user is a member of.
  ///
  /// Defaults to membership, most recently active first — the order that puts
  /// what someone is working on at the top. Pagination is by page number; the
  /// next cursor comes from the response headers, never an assumed count.
  Future<Paginated<Project>> list({int page = 1, int perPage = 20}) async {
    try {
      // Untyped, so an error body (which GitLab returns as an object, not a
      // list) does not fail a List cast before the status can be inspected.
      final response = await _dio.get<dynamic>(
        '/projects',
        queryParameters: {
          'membership': true,
          'order_by': 'last_activity_at',
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading projects',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      final projects = data.map(Project.fromJson).toList(growable: false);
      return Paginated.fromHeaders(projects, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading projects');
    }
  }
}
