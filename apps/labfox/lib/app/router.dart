import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_controller.dart';
import '../core/auth/auth_state.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/branches/presentation/branches_screen.dart';
import '../features/commits/presentation/commit_detail_screen.dart';
import '../features/commits/presentation/commits_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/issues/presentation/issue_detail_screen.dart';
import '../features/issues/presentation/issues_screen.dart';
import '../features/project_overview/presentation/project_overview_screen.dart';
import '../features/projects/presentation/projects_screen.dart';
import '../features/repository/presentation/file_viewer_screen.dart';
import '../features/repository/presentation/repository_browser_screen.dart';

/// Route paths.
///
/// Paths mirror GitLab's own URL shape so a deep link from the web can map
/// straight onto a screen. The number in a merge request or issue path is the
/// `iid`, the per-project number a user sees, never the global `id`.
abstract final class Routes {
  static const String home = '/';
  static const String signIn = '/sign-in';
  static const String projects = '/projects';

  static String projectOverview(int id) => '/projects/$id';

  // Repository browsing. The tree path and file path travel as a query
  // parameter, not a nested segment, because a repository path contains its own
  // slashes; encoding it as one query value keeps go_router from splitting it
  // into route segments.
  static String repository(int id, String ref) =>
      '/projects/$id/tree?ref=${Uri.encodeQueryComponent(ref)}';
  static String repositoryPath(int id, String ref, String path) =>
      '/projects/$id/tree?ref=${Uri.encodeQueryComponent(ref)}'
      '&path=${Uri.encodeQueryComponent(path)}';
  static String file(int id, String ref, String path) =>
      '/projects/$id/file?ref=${Uri.encodeQueryComponent(ref)}'
      '&path=${Uri.encodeQueryComponent(path)}';
  static String branches(int id) => '/projects/$id/branches';
  static String commits(int id, String ref) =>
      '/projects/$id/commits?ref=${Uri.encodeQueryComponent(ref)}';
  static String commit(int id, String sha) => '/projects/$id/commit/$sha';
  static String issues(int id) => '/projects/$id/issues';
  // The user-facing issue number is the iid, not the global id.
  static String issue(int id, int iid) => '/projects/$id/issues/$iid';
}

final routerProvider = Provider<GoRouter>((ref) {
  // Rebuild the router when auth changes so the redirect below re-runs and the
  // user is moved between the sign-in screen and the app.
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: Routes.home,
    redirect: (context, state) {
      // Only wait during the very first load, before any session value
      // exists, so a returning user is not flashed the sign-in screen before
      // their persisted account is read. A failed sign-in attempt is an error
      // that still carries the previous SignedOut value, so it must NOT be
      // treated as "no opinion" — routing is decided by whether a session
      // exists, never by the transient state of a sign-in attempt.
      if (authState.isLoading && !authState.hasValue) {
        return null;
      }
      final signedIn = authState.valueOrNull is SignedIn;
      final atSignIn = state.matchedLocation == Routes.signIn;

      if (!signedIn) {
        return atSignIn ? null : Routes.signIn;
      }
      if (atSignIn) {
        return Routes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: Routes.projects,
        builder: (context, state) => const ProjectsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return ProjectOverviewScreen(projectId: id);
            },
            routes: [
              GoRoute(
                path: 'tree',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  final ref = state.uri.queryParameters['ref']!;
                  final path = state.uri.queryParameters['path'] ?? '';
                  return RepositoryBrowserScreen(
                    projectId: id,
                    ref: ref,
                    path: path,
                  );
                },
              ),
              GoRoute(
                path: 'file',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  final ref = state.uri.queryParameters['ref']!;
                  final path = state.uri.queryParameters['path']!;
                  return FileViewerScreen(projectId: id, ref: ref, path: path);
                },
              ),
              GoRoute(
                path: 'branches',
                builder: (context, state) => BranchesScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'commits',
                builder: (context, state) => CommitsScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                  ref: state.uri.queryParameters['ref']!,
                ),
              ),
              GoRoute(
                path: 'commit/:sha',
                builder: (context, state) => CommitDetailScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                  sha: state.pathParameters['sha']!,
                ),
              ),
              GoRoute(
                path: 'issues',
                builder: (context, state) => IssuesScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'issues/:iid',
                builder: (context, state) => IssueDetailScreen(
                  projectId: int.parse(state.pathParameters['id']!),
                  iid: int.parse(state.pathParameters['iid']!),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
