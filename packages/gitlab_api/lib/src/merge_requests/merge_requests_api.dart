import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Which merge requests to list.
enum MergeRequestState {
  opened('opened'),
  merged('merged'),
  closed('closed'),
  all('all');

  const MergeRequestState(this.value);

  final String value;
}

/// Merge request endpoints.
class MergeRequestsApi {
  const MergeRequestsApi(this._dio);

  final Dio _dio;

  /// Lists a project's merge requests, open by default, most recently updated
  /// first.
  Future<Paginated<MergeRequest>> list(
    Object projectId, {
    MergeRequestState state = MergeRequestState.opened,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/merge_requests',
        queryParameters: {
          if (state != MergeRequestState.all) 'state': state.value,
          'order_by': 'updated_at',
          // Labels as objects with colours, not bare names.
          'with_labels_details': true,
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing merge requests',
        );
      }
      final mrs = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(MergeRequest.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(mrs, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing merge requests');
    }
  }

  /// A single merge request by its `iid`.
  Future<MergeRequest> get(Object projectId, {required int iid}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/merge_requests/$iid',
        queryParameters: {'with_labels_details': true},
      );
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the merge request',
        );
      }
      return MergeRequest.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the merge request');
    }
  }

  /// The files changed by a merge request, as parsed diffs.
  Future<List<FileDiff>> diffs(Object projectId, {required int iid}) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/diffs',
        // unidiff=true guarantees the unified-diff format the parser expects.
        queryParameters: {'unidiff': true},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the merge request diff',
        );
      }
      return (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(FileDiff.fromJson)
          .toList(growable: false);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the merge request diff');
    }
  }

  static String _enc(Object projectId) =>
      projectId is int ? '$projectId' : Uri.encodeComponent('$projectId');
}
