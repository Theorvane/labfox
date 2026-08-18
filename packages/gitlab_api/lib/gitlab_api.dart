/// GitLab REST client for LabFox.
///
/// Pure Dart: this package must never import `package:flutter`, so it stays
/// unit testable without a widget binding.
library;

export 'src/common/exceptions.dart';
export 'src/common/paginated.dart';
export 'src/gitlab_client.dart';
export 'src/projects/projects_api.dart';
export 'src/users/users_api.dart';
