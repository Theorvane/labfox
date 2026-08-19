import 'oauth_config.dart';

/// Where the OAuth browser flow sends the user back, and how to capture it.
///
/// The redirect differs by platform: mobile and macOS use the custom
/// [OAuthConfig.callbackScheme] (handled natively by the in-app browser
/// session), while Windows and Linux capture the redirect with a localhost
/// loopback server, which requires an `http://localhost:{port}` redirect.
class OAuthRedirect {
  const OAuthRedirect({
    required this.redirectUri,
    required this.callbackScheme,
    this.useWebview = true,
  });

  /// Sent to the authorization server and used in the token exchange. Must
  /// exactly match a redirect URI registered on the OAuth application.
  final String redirectUri;

  /// Passed to the browser session so it knows which redirect to intercept.
  final String callbackScheme;

  /// Whether flutter_web_auth_2 uses a webview. On desktop this is `false` so
  /// the loopback server captures the redirect and no webview runtime is
  /// needed.
  final bool useWebview;
}

/// Resolves the redirect for the current platform.
///
/// [isDesktopLoopback] is true only for Windows and Linux; macOS keeps the
/// custom scheme because its in-app browser session handles it natively.
OAuthRedirect resolveOAuthRedirect({
  required bool isDesktopLoopback,
  int loopbackPort = 8620,
}) {
  if (isDesktopLoopback) {
    final origin = 'http://localhost:$loopbackPort';
    return OAuthRedirect(
      redirectUri: origin,
      callbackScheme: origin,
      useWebview: false,
    );
  }
  return const OAuthRedirect(
    redirectUri: OAuthConfig.redirectUri,
    callbackScheme: OAuthConfig.callbackScheme,
  );
}
