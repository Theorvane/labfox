import 'package:gitlab_models/gitlab_models.dart';

/// The authentication state the app routes on.
sealed class AuthState {
  const AuthState();
}

/// No account is connected. The user sees the sign-in screen.
class SignedOut extends AuthState {
  const SignedOut();
}

/// An account is connected.
class SignedIn extends AuthState {
  const SignedIn(this.account);

  final Account account;
}
