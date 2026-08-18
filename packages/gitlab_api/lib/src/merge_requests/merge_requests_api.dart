import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/exceptions.dart';
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

  /// Approves a merge request.
  Future<void> approve(Object projectId, {required int iid}) =>
      _postAction(projectId, iid: iid, action: 'approve');

  /// Removes the current user's approval.
  Future<void> unapprove(Object projectId, {required int iid}) =>
      _postAction(projectId, iid: iid, action: 'unapprove');

  Future<void> _postAction(
    Object projectId, {
    required int iid,
    required String action,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/$action',
      );
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating the approval',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'updating the approval');
    }
  }

  /// The approval state of a merge request.
  Future<MergeRequestApprovals> approvals(
    Object projectId, {
    required int iid,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/approvals',
      );
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading approvals',
        );
      }
      return MergeRequestApprovals.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading approvals');
    }
  }

  /// Merges a merge request and returns the updated (merged) resource.
  ///
  /// A 405/406/409 means the request is not mergeable in its current state —
  /// distinct from a 403 (no permission) — so it maps to its own exception the
  /// UI can explain.
  Future<MergeRequest> merge(Object projectId, {required int iid}) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/merge_requests/$iid/merge',
      );
      final status = response.statusCode ?? 0;
      if (status == 405 || status == 406 || status == 409) {
        throw GitLabNotMergeableException(
          'This merge request cannot be merged in its current state.',
          statusCode: status,
        );
      }
      final data = response.data;
      if (status != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'merging',
        );
      }
      return MergeRequest.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'merging');
    }
  }

  static String _enc(Object projectId) =>
      projectId is int ? '$projectId' : Uri.encodeComponent('$projectId');
}
