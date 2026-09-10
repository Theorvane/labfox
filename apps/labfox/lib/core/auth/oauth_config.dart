import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the browser authorization option is offered on this platform.
///
/// It is not, on Apple's. App Store Review rejected LabFox three times under
/// guideline 4.8 — which asks an app offering a third-party login service to
/// offer another one beside it — twice after being told why the guideline does
/// not apply: LabFox has no account for a login service to establish, and 4.8
/// exempts a client whose users sign in to their own third-party account to
/// reach their own content. The reading did not change, and a fourth attempt
/// at explaining it would cost another review cycle to find that out again.
///
/// What is left on iOS and macOS is a personal access token the user issued to
/// themselves on their own GitLab. That is a credential, not a login service,
/// so there is nothing for the guideline to attach to. Every other platform
/// keeps the browser flow: the constraint is Apple's, and there is no reason
/// to spend an Android user's convenience on it.
final browserAuthorizationProvider = Provider<bool>((ref) {
  return !Platform.isIOS && !Platform.isMacOS;
});

/// Static OAuth configuration.
///
/// The gitlab.com application id ships with the build via a dart-define so it
/// is not committed to source. Self-hosted instances supply their own client
/// id at sign-in, because each instance registers its own OAuth application.
abstract final class OAuthConfig {
  /// The registered client id for gitlab.com, injected at build time:
  /// `--dart-define=GITLAB_OAUTH_CLIENT_ID=...`. Empty when not configured, in
  /// which case gitlab.com OAuth is offered only if the user enters an id.
  static const String gitlabComClientId = String.fromEnvironment(
    'GITLAB_OAUTH_CLIENT_ID',
  );

  /// The custom URL scheme the browser redirects back to. Registered natively
  /// on each platform.
  static const String callbackScheme = 'labfox';

  /// The full redirect URI registered with the OAuth application.
  static const String redirectUri = 'labfox://oauth-callback';

  /// Full API access, matching the PAT flow's capabilities.
  static const String scope = 'api';

  static bool get hasGitlabComClientId => gitlabComClientId.isNotEmpty;
}
