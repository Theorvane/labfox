import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';

/// Route paths.
///
/// Paths mirror GitLab's own URL shape so a deep link from the web can map
/// straight onto a screen. The number in a merge request or issue path is the
/// `iid`, the per-project number a user sees, never the global `id`.
abstract final class Routes {
  static const String home = '/';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
