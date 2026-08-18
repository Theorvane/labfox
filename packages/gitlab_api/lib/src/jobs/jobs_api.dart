import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

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

  static String _enc(Object projectId) =>
      projectId is int ? '$projectId' : Uri.encodeComponent('$projectId');
}
