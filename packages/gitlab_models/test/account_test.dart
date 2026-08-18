import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  const user = User(id: 42, username: 'jungwon', name: 'Jungwon');

  group('Account.id', () {
    test('combines host and user id', () {
      const account = Account(instanceUrl: 'https://gitlab.com', user: user);
      expect(account.id, 'gitlab.com/42');
    });

    test('separates the same user id on different instances', () {
      // User ids are only unique per instance, so the host has to be part of
      // the identity or two accounts would collide.
      const a = Account(instanceUrl: 'https://gitlab.com', user: user);
      const b = Account(instanceUrl: 'https://git.company.com', user: user);
      expect(a.id, isNot(b.id));
    });
  });

  group('Account json', () {
    test('round-trips through json', () {
      const account = Account(instanceUrl: 'https://gitlab.com', user: user);
      final restored = Account.fromJson(account.toJson());
      expect(restored, account);
    });

    test('carries no token field', () {
      // The token lives in secure storage; it must never be serialised with the
      // account metadata.
      const account = Account(instanceUrl: 'https://gitlab.com', user: user);
      expect(account.toJson().keys, isNot(contains('token')));
    });
  });
}
