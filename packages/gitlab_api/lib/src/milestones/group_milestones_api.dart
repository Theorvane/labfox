import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Read-only group milestone endpoints.
class GroupMilestonesApi {
  const GroupMilestonesApi(this._dio);

  final Dio _dio;

  String _path(Object groupId) =>
      '/groups/${Uri.encodeComponent(groupId.toString())}/milestones';

  Future<Paginated<GitLabMilestone>> list(
    Object groupId, {
    int page = 1,
    int perPage = 20,
    String? state,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(groupId),
        queryParameters: {'page': page, 'per_page': perPage, 'state': ?state},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing group milestones',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(GitLabMilestone.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing group milestones');
    }
  }

  /// [milestoneId] is global, not the group-local iid.
  Future<GitLabMilestone> get(Object groupId, int milestoneId) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(groupId)}/$milestoneId',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a group milestone',
        );
      }
      return GitLabMilestone.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a group milestone');
    }
  }
}
