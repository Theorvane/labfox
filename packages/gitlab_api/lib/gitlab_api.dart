/// GitLab REST client for LabFox.
///
/// Pure Dart: this package must never import `package:flutter`, so it stays
/// unit testable without a widget binding.
library;

export 'src/common/exceptions.dart';
export 'src/common/paginated.dart';
export 'src/gitlab_client.dart';
export 'src/groups/groups_api.dart';
export 'src/issues/issues_api.dart';
export 'src/jobs/jobs_api.dart';
export 'src/merge_requests/merge_requests_api.dart';
export 'src/notes/notes_api.dart';
export 'src/oauth/oauth_api.dart';
export 'src/oauth/pkce.dart';
export 'src/pipelines/pipelines_api.dart';
export 'src/projects/projects_api.dart';
export 'src/repository/repository_api.dart';
export 'src/repository/repository_file.dart';
export 'src/search/search_api.dart';
export 'src/todos/todos_api.dart';
export 'src/users/users_api.dart';
