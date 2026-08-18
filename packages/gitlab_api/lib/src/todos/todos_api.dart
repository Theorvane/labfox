import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Which todos to list.
enum TodoState {
  pending('pending'),
  done('done');

  const TodoState(this.value);

  final String value;
}

/// The current user's To-do list — `/todos`.
///
/// These are account-scoped, not project-scoped: the endpoint always acts on
/// the authenticated user, so none of these calls take a project id.
class TodosApi {
  const TodosApi(this._dio);

  final Dio _dio;

  /// Lists the current user's todos, pending by default, newest first.
  Future<Paginated<Todo>> list({
    TodoState state = TodoState.pending,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/todos',
        queryParameters: {
          'state': state.value,
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing your to-do items',
        );
      }
      final todos = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Todo.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(todos, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing your to-do items');
    }
  }

  /// Marks a single todo as done.
  Future<void> markDone(int id) async {
    try {
      final response = await _dio.post<dynamic>('/todos/$id/mark_as_done');
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'clearing the to-do item',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'clearing the to-do item');
    }
  }

  /// Marks every pending todo as done.
  Future<void> markAllDone() async {
    try {
      final response = await _dio.post<dynamic>('/todos/mark_as_done');
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'clearing your to-do items',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'clearing your to-do items');
    }
  }
}
