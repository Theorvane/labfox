import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/core/auth/oauth_redirect.dart';

void main() {
  group('resolveOAuthRedirect', () {
    test('uses the custom scheme on mobile and macOS', () {
      final redirect = resolveOAuthRedirect(isDesktopLoopback: false);

      expect(redirect.redirectUri, 'labfox://oauth-callback');
      expect(redirect.callbackScheme, 'labfox');
      // ASWebAuthenticationSession / custom-tab handles the scheme itself.
      expect(redirect.useWebview, isTrue);
    });

    test('uses a localhost loopback on Windows and Linux', () {
      final redirect = resolveOAuthRedirect(
        isDesktopLoopback: true,
        loopbackPort: 8620,
      );

      // The redirect the OAuth app registers and the scheme the browser is sent
      // back to are the same localhost origin.
      expect(redirect.redirectUri, 'http://localhost:8620');
      expect(redirect.callbackScheme, 'http://localhost:8620');
      // The loopback server, not a webview, captures the redirect — so no
      // extra webview runtime is required.
      expect(redirect.useWebview, isFalse);
    });
  });
}
