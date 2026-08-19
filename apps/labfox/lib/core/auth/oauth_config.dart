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
