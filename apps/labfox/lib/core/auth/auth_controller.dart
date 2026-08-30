import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../analytics/analytics.dart';
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
      unawaited(ref.read(analyticsProvider).track('sign_in'));
      return SignedIn(account);
    });
  }

  /// Runs the OAuth browser flow and, on success, moves the app to signed in.
  ///
  /// Like [signIn], a failure (cancelled, denied, or tampered) sets the error
  /// state and leaves the current session untouched.
  Future<void> signInWithOAuth({
    required String instanceUrl,
    required String clientId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final account = await ref
          .read(authRepositoryProvider)
          .signInWithOAuth(instanceUrl: instanceUrl, clientId: clientId);
      unawaited(ref.read(analyticsProvider).track('sign_in'));
      return SignedIn(account);
    });
  }

  /// All connected accounts, for the switcher UI.
  List<Account> accounts() => ref.read(authRepositoryProvider).accounts();

  /// Switches the active account and reflects it in the session.
  ///
  /// Account-scoped providers watch the active account, so switching here
  /// invalidates them and their data reloads for the new account.
  Future<void> switchTo(Account account) async {
    await ref.read(authRepositoryProvider).switchTo(account);
    unawaited(ref.read(analyticsProvider).track('account_switched'));
    state = AsyncData(SignedIn(account));
  }

  /// Removes an account. If it was active, the session falls back to another
  /// connected account, or to signed out when none remain.
  Future<void> signOut([Account? account]) async {
    final repo = ref.read(authRepositoryProvider);
    final current = state.valueOrNull;
    final target = account ?? (current is SignedIn ? current.account : null);
    if (target == null) {
      return;
    }
    await repo.signOut(target);
    unawaited(ref.read(analyticsProvider).track('sign_out'));
    final next = repo.currentAccount();
    state = AsyncData(next == null ? const SignedOut() : SignedIn(next));
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
