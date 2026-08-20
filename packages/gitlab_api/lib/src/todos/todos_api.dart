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

/// What a todo points at, for the type filter.
enum TodoType {
  issue('Issue'),
  mergeRequest('MergeRequest');

  const TodoType(this.value);

  final String value;
}

/// Why a todo exists, for the reason filter.
enum TodoAction {
  assigned('assigned'),
  mentioned('mentioned'),
  buildFailed('build_failed'),
  marked('marked'),
  approvalRequired('approval_required'),
  unmergeable('unmergeable'),
  directlyAddressed('directly_addressed');

  const TodoAction(this.value);

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
  ///
  /// [type] and [action] narrow by target and reason; null means unfiltered.
  Future<Paginated<Todo>> list({
    TodoState state = TodoState.pending,
    TodoType? type,
    TodoAction? action,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/todos',
        queryParameters: {
          'state': state.value,
          if (type != null) 'type': type.value,
          if (action != null) 'action': action.value,
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

  /// Every todo for the current user in the given state, following pagination
  /// to the last page.
  ///
  /// The inbox needs the whole list — a fixed page would silently hide items
  /// past the first page, so the user could neither open nor clear them.
  Future<List<Todo>> listAll({
    TodoState state = TodoState.pending,
    TodoType? type,
    TodoAction? action,
    int perPage = 100,
  }) async {
    try {
      final todos = <Todo>[];
      int? page = 1;
      while (page != null) {
        final response = await _dio.get<dynamic>(
          '/todos',
          queryParameters: {
            'state': state.value,
            if (type != null) 'type': type.value,
            if (action != null) 'action': action.value,
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
        todos.addAll(
          (response.data as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>()
              .map(Todo.fromJson),
        );
        final next = response.headers.value('x-next-page');
        page = (next == null || next.isEmpty) ? null : int.tryParse(next);
      }
      return List.unmodifiable(todos);
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
