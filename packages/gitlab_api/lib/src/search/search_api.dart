import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Global search — `/search`.
///
/// One page of ranked results per call. Search is inherently ranked, so the
/// caller pages through with [Paginated.nextPage] rather than fetching every
/// page at once.
class SearchApi {
  const SearchApi(this._dio);

  final Dio _dio;

  Future<Paginated<Project>> projects(
    String query, {
    int page = 1,
    int perPage = 20,
  }) => _search('projects', query, Project.fromJson, page, perPage);

  Future<Paginated<Issue>> issues(
    String query, {
    int page = 1,
    int perPage = 20,
  }) => _search('issues', query, Issue.fromJson, page, perPage);

  Future<Paginated<MergeRequest>> mergeRequests(
    String query, {
    int page = 1,
    int perPage = 20,
  }) => _search('merge_requests', query, MergeRequest.fromJson, page, perPage);

  Future<Paginated<T>> _search<T>(
    String scope,
    String query,
    T Function(Map<String, dynamic>) fromJson,
    int page,
    int perPage,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        '/search',
        queryParameters: {
          'scope': scope,
          'search': query,
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'searching',
        );
      }
      final items = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(items, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'searching');
    }
  }
}
