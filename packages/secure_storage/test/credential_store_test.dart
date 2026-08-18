import 'package:flutter_test/flutter_test.dart';
import 'package:secure_storage/secure_storage.dart';

void main() {
  group('CredentialStore.keyFor', () {
    test('namespaces by host, user and kind', () {
      expect(
        CredentialStore.keyFor(
          instanceUrl: 'https://gitlab.com',
          userId: 42,
          kind: 'pat',
        ),
        'labfox/gitlab.com/42/pat',
      );
    });

    test('separates the same host on different ports', () {
      final a = CredentialStore.keyFor(
        instanceUrl: 'https://gitlab.example',
        userId: 1,
        kind: 'pat',
      );
      final b = CredentialStore.keyFor(
        instanceUrl: 'https://gitlab.example:8443',
        userId: 1,
        kind: 'pat',
      );
      expect(a, isNot(b));
    });

    test('separates the same user id on different instances', () {
      // Multi-account is a core feature and user ids are only unique per
      // instance, so a key that ignored the host would cross the streams.
      final a = CredentialStore.keyFor(
        instanceUrl: 'https://gitlab.com',
        userId: 1,
        kind: 'pat',
      );
      final b = CredentialStore.keyFor(
        instanceUrl: 'https://git.company.com',
        userId: 1,
        kind: 'pat',
      );

      expect(a, isNot(b));
    });

    test('separates token kinds for one account', () {
      final access = CredentialStore.keyFor(
        instanceUrl: 'https://gitlab.com',
        userId: 1,
        kind: 'oauth_access',
      );
      final refresh = CredentialStore.keyFor(
        instanceUrl: 'https://gitlab.com',
        userId: 1,
        kind: 'oauth_refresh',
      );

      expect(access, isNot(refresh));
    });

    test('rejects an instance URL with no host', () {
      expect(
        () => CredentialStore.keyFor(
          instanceUrl: 'not-a-url',
          userId: 1,
          kind: 'pat',
        ),
        throwsArgumentError,
      );
    });
  });
}
