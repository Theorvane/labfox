import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('OAuthToken', () {
    final json = {
      'access_token': 'at-123',
      'token_type': 'bearer',
      'expires_in': 7200,
      'refresh_token': 'rt-456',
      'created_at': 1607635748,
      'scope': 'api',
    };

    test('parses the token endpoint response', () {
      final token = OAuthToken.fromJson(json);

      expect(token.accessToken, 'at-123');
      expect(token.refreshToken, 'rt-456');
      expect(token.tokenType, 'bearer');
      expect(token.expiresIn, 7200);
      expect(token.createdAt, 1607635748);
      expect(token.scope, 'api');
    });

    test('round-trips through json', () {
      expect(
        OAuthToken.fromJson(json).toJson(),
        containsPair('access_token', 'at-123'),
      );
      expect(
        OAuthToken.fromJson(OAuthToken.fromJson(json).toJson()).refreshToken,
        'rt-456',
      );
    });

    test('is expired once created_at + expires_in has passed', () {
      final token = OAuthToken.fromJson(json);
      // created_at 1607635748 + 7200 = 1607642948
      expect(token.isExpiredAt(1607642949), isTrue);
      expect(token.isExpiredAt(1607635748), isFalse);
    });

    test('treats a near-expiry token as expired within the leeway', () {
      final token = OAuthToken.fromJson(json);
      // 30s before the hard expiry, with a 60s leeway, counts as expired so a
      // refresh happens before a request can fail mid-flight.
      expect(token.isExpiredAt(1607642918, leewaySeconds: 60), isTrue);
      expect(token.isExpiredAt(1607642918, leewaySeconds: 10), isFalse);
    });
  });
}
