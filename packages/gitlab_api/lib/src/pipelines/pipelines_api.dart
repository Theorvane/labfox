import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Pipeline and job endpoints.
class PipelinesApi {
  const PipelinesApi(this._dio);

  final Dio _dio;

  /// Lists a project's pipelines, most recent first.
  Future<Paginated<Pipeline>> list(
    Object projectId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/pipelines',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing pipelines',
        );
      }
      final pipelines = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Pipeline.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(pipelines, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing pipelines');
    }
  }

  /// A single pipeline by id.
  Future<Pipeline> get(Object projectId, {required int pipelineId}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/pipelines/$pipelineId',
      );
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the pipeline',
        );
      }
      return Pipeline.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the pipeline');
    }
  }

  /// The jobs of a pipeline, in GitLab's order.
  Future<List<Job>> jobs(Object projectId, {required int pipelineId}) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/pipelines/$pipelineId/jobs',
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading jobs',
        );
      }
      return (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Job.fromJson)
          .toList(growable: false);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading jobs');
    }
  }

  static String _enc(Object projectId) =>
      projectId is int ? '$projectId' : Uri.encodeComponent('$projectId');
}
