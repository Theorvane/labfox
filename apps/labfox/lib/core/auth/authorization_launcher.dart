import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

/// Opens the OAuth authorization URL in the system browser and returns the
/// redirect the browser is sent back to.
///
/// Behind an interface so the sign-in flow can be tested without a real
/// browser: a fake launcher echoes back a redirect with the expected code and
/// state.
abstract interface class AuthorizationLauncher {
  Future<Uri> authorize({required Uri url, required String callbackScheme});
}

/// The real launcher, backed by `flutter_web_auth_2`. It opens an in-app secure
/// browser tab and completes when the page redirects to [callbackScheme].
class WebAuthLauncher implements AuthorizationLauncher {
  const WebAuthLauncher();

  @override
  Future<Uri> authorize({
    required Uri url,
    required String callbackScheme,
  }) async {
    final result = await FlutterWebAuth2.authenticate(
      url: url.toString(),
      callbackUrlScheme: callbackScheme,
    );
    return Uri.parse(result);
  }
}
