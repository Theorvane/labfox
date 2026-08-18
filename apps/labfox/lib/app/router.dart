import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_controller.dart';
import '../core/auth/auth_state.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/home/presentation/home_screen.dart';

/// Route paths.
///
/// Paths mirror GitLab's own URL shape so a deep link from the web can map
/// straight onto a screen. The number in a merge request or issue path is the
/// `iid`, the per-project number a user sees, never the global `id`.
abstract final class Routes {
  static const String home = '/';
  static const String signIn = '/sign-in';
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
    ],
  );
});
