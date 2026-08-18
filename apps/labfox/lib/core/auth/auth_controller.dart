import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'auth_providers.dart';
import 'auth_state.dart';

/// Owns the session and the sign-in / sign-out transitions.
///
/// The router watches this to decide between the sign-in screen and the app.
class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final account = ref.read(authRepositoryProvider).currentAccount();
    return account == null ? const SignedOut() : SignedIn(account);
  }

  /// Validates the token and, on success, moves the app to signed in.
  ///
  /// A failure sets the error state and leaves the session untouched, so a bad
  /// attempt cannot sign the current account out.
  Future<void> signIn({
    required String instanceUrl,
    required String token,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final account = await ref
          .read(authRepositoryProvider)
          .signInWithToken(instanceUrl: instanceUrl, token: token);
      return SignedIn(account);
    });
  }

  Future<void> signOut() async {
    final current = state.valueOrNull;
    if (current is! SignedIn) {
      return;
    }
    await ref.read(authRepositoryProvider).signOut(current.account);
    state = const AsyncData(SignedOut());
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// The signed-in account, or null. Convenience for screens that only need to
/// read who is signed in.
final currentAccountProvider = Provider<Account?>((ref) {
  final state = ref.watch(authControllerProvider).valueOrNull;
  return state is SignedIn ? state.account : null;
});
