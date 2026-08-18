import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/exceptions.dart';
import '../gitlab_client.dart';

/// Job detail and trace (log) endpoints.
class JobsApi {
  const JobsApi(this._dio);

  final Dio _dio;

  /// A single job by id.
  Future<Job> get(Object projectId, {required int jobId}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/jobs/$jobId',
      );
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the job',
        );
      }
      return Job.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the job');
    }
  }

  /// The raw trace (log) of a job.
  ///
  /// Plain text with ANSI escape codes, not JSON — the caller parses it. An
  /// empty string means the job has produced no output yet.
  Future<String> trace(Object projectId, {required int jobId}) async {
    try {
      final response = await _dio.get<String>(
        '/projects/${_enc(projectId)}/jobs/$jobId/trace',
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the job log',
        );
      }
      return response.data ?? '';
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the job log');
    }
  }

  /// Retries a finished job, returning the new run.
  Future<Job> retry(Object projectId, {required int jobId}) =>
      _action(projectId, jobId: jobId, action: 'retry');

  /// Cancels a running job.
  Future<Job> cancel(Object projectId, {required int jobId}) =>
      _action(projectId, jobId: jobId, action: 'cancel');

  /// Runs a manual job.
  Future<Job> play(Object projectId, {required int jobId}) =>
      _action(projectId, jobId: jobId, action: 'play');

  Future<Job> _action(
    Object projectId, {
    required int jobId,
    required String action,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/jobs/$jobId/$action',
      );
      final status = response.statusCode ?? 0;
      // 409/422: the job is not in a state that allows this action — distinct
      // from a 403 (no permission).
      if (status == 409 || status == 422) {
        throw GitLabConflictException(
          'This job cannot be $action-ed in its current state.',
          statusCode: status,
        );
      }
      final data = response.data;
      if (status < 200 || status >= 300 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating the job',
        );
      }
      return Job.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating the job');
    }
  }

  static String _enc(Object projectId) =>
      projectId is int ? '$projectId' : Uri.encodeComponent('$projectId');
}
