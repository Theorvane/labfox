import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'oauth_redirect.dart';

/// Opens the OAuth authorization URL in the system browser and returns the
/// redirect the browser is sent back to.
///
/// Behind an interface so the sign-in flow can be tested without a real
/// browser: a fake launcher echoes back a redirect with the expected code and
/// state.
abstract interface class AuthorizationLauncher {
  Future<Uri> authorize({required Uri url, required OAuthRedirect redirect});
}

/// The real launcher, backed by `flutter_web_auth_2`. On mobile and macOS it
/// opens an in-app secure browser tab keyed to the custom scheme; on Windows
/// and Linux it runs a localhost loopback server ([OAuthRedirect.useWebview]
/// is false) so no webview runtime is required.
class WebAuthLauncher implements AuthorizationLauncher {
  const WebAuthLauncher();

  @override
  Future<Uri> authorize({
    required Uri url,
    required OAuthRedirect redirect,
  }) async {
    final result = await FlutterWebAuth2.authenticate(
      url: url.toString(),
      callbackUrlScheme: redirect.callbackScheme,
      options: FlutterWebAuth2Options(useWebview: redirect.useWebview),
    );
    return Uri.parse(result);
  }
}
