import 'package:dio/dio.dart';

import 'common/exceptions.dart';
import 'issues/issues_api.dart';
import 'jobs/jobs_api.dart';
import 'merge_requests/merge_requests_api.dart';
import 'notes/notes_api.dart';
import 'pipelines/pipelines_api.dart';
import 'projects/projects_api.dart';
import 'repository/repository_api.dart';
import 'search/search_api.dart';
import 'todos/todos_api.dart';
import 'users/users_api.dart';

/// Entry point for every GitLab REST call.
///
/// One client is bound to one account: a base URL and a token. Switching
/// accounts means building a new client, never mutating this one, so a request
/// in flight cannot end up authenticated as somebody else.
class GitLabClient {
  GitLabClient({required String baseUrl, required String token, Dio? dio})
    : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = apiBaseUrl(baseUrl)
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 30)
      ..headers['PRIVATE-TOKEN'] = token
      // GitLab returns 4xx as a normal response so error bodies can be read
      // and turned into domain exceptions rather than raw transport errors.
      ..validateStatus = (status) => status != null && status < 500;

    users = UsersApi(_dio);
    projects = ProjectsApi(_dio);
    repository = RepositoryApi(_dio);
    issues = IssuesApi(_dio);
    mergeRequests = MergeRequestsApi(_dio);
    notes = NotesApi(_dio);
    pipelines = PipelinesApi(_dio);
    jobs = JobsApi(_dio);
    todos = TodosApi(_dio);
    search = SearchApi(_dio);
  }

  final Dio _dio;

  late final UsersApi users;
  late final ProjectsApi projects;
  late final RepositoryApi repository;
  late final IssuesApi issues;
  late final MergeRequestsApi mergeRequests;
  late final NotesApi notes;
  late final PipelinesApi pipelines;
  late final JobsApi jobs;
  late final TodosApi todos;
  late final SearchApi search;

  /// Derives the REST endpoint from an instance URL.
  ///
  /// The instance URL comes from the user, so `gitlab.com` is never hardcoded:
  /// `https://git.company.com` becomes `https://git.company.com/api/v4`.
  /// Trailing slashes are tolerated because people paste them.
  static String apiBaseUrl(String instanceUrl) {
    final trimmed = instanceUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        instanceUrl,
        'instanceUrl',
        'must not be empty',
      );
    }
    if (trimmed.endsWith('/api/v4')) {
      return trimmed;
    }
    return '$trimmed/api/v4';
  }

  void close() => _dio.close();
}

/// Translates a transport or HTTP failure into a [GitLabException].
///
/// Lives next to the client so every API surface reports failures the same way.
GitLabException mapError(Object error, {String? context}) {
  final where = context == null ? '' : ' while $context';

  if (error is DioException) {
    final response = error.response;
    if (response == null) {
      return GitLabConnectionException(
        'Could not reach the GitLab instance$where. Check the instance URL, '
        'your network, and whether the certificate is trusted.',
      );
    }
    return mapStatus(
      response.statusCode,
      response.headers.map,
      context: context,
    );
  }

  return GitLabServerException('Unexpected error$where: $error');
}

/// Translates a status code into a [GitLabException].
GitLabException mapStatus(
  int? status,
  Map<String, List<String>> headers, {
  String? context,
}) {
  final where = context == null ? '' : ' while $context';

  switch (status) {
    case 401:
      return GitLabAuthException(
        'The token was rejected$where. It may be expired or revoked.',
        statusCode: status,
      );
    case 403:
      return GitLabForbiddenException(
        'The token lacks permission$where. Check its scopes and your role.',
        statusCode: status,
      );
    case 404:
      return GitLabNotFoundException(
        'Not found$where. The resource may not exist, or the token may not be '
        'allowed to see it.',
        statusCode: status,
      );
    case 429:
      final raw = headers['retry-after']?.firstOrNull;
      final seconds = raw == null ? null : int.tryParse(raw);
      return GitLabRateLimitException(
        'Rate limited$where.',
        statusCode: status,
        retryAfter: seconds == null ? null : Duration(seconds: seconds),
      );
    default:
      return GitLabServerException(
        'The GitLab instance returned $status$where.',
        statusCode: status,
      );
  }
}
