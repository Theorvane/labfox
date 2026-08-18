import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Which issues to list.
enum IssueState {
  opened('opened'),
  closed('closed'),
  all('all');

  const IssueState(this.value);

  final String value;
}

/// Issue endpoints.
class IssuesApi {
  const IssuesApi(this._dio);

  final Dio _dio;

  /// Lists a project's issues, open by default, most recently updated first.
  Future<Paginated<Issue>> list(
    Object projectId, {
    IssueState state = IssueState.opened,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/issues',
        queryParameters: {
          if (state != IssueState.all) 'state': state.value,
          'order_by': 'updated_at',
          // Return each label as an object with its colour, not a bare name, so
          // the UI can render readable label chips.
          'with_labels_details': true,
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing issues',
        );
      }
      final issues = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Issue.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(issues, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing issues');
    }
  }

  /// A single issue by its `iid` — the per-project number a user sees, never
  /// the global `id`.
  Future<Issue> get(Object projectId, {required int iid}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/issues/$iid',
        queryParameters: {'with_labels_details': true},
      );
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the issue',
        );
      }
      return Issue.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the issue');
    }
  }

  static String _enc(Object projectId) =>
      projectId is int ? '$projectId' : Uri.encodeComponent('$projectId');
}
