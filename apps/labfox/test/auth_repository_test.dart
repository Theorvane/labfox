import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:labfox/core/auth/account_store.dart';
import 'package:labfox/core/auth/auth_repository.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_dio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AccountStore accountStore;
  late CredentialStore credentialStore;

  // A token is valid only when it equals this; anything else 401s, the way a
  // real instance rejects a bad token.
  const goodToken = 'glpat-valid';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    accountStore = AccountStore(await SharedPreferences.getInstance());
    credentialStore = CredentialStore();
  });

  AuthRepository buildRepo() {
    return AuthRepository(
      accountStore: accountStore,
      credentialStore: credentialStore,
      clientFactory: ({required String baseUrl, required String token}) {
        return GitLabClient(
          baseUrl: baseUrl,
          token: token,
          dio: fakeDio((options) {
            if (token != goodToken) {
              return (status: 401, body: {'message': '401 Unauthorized'});
            }
            return (
              status: 200,
              body: {'id': 42, 'username': 'jungwon', 'name': 'Jungwon'},
            );
          }),
        );
      },
    );
  }

  test('a valid token persists the account and stores the token', () async {
    final repo = buildRepo();

    final account = await repo.signInWithToken(
      instanceUrl: 'https://gitlab.com',
      token: goodToken,
    );

    expect(account.user.username, 'jungwon');
    // Persisted, so a restart stays signed in.
    expect(accountStore.readActive()?.user.id, account.user.id);
    // The token went to secure storage, reachable through the repository.
    expect(await repo.tokenFor(account), goodToken);
  });

  test('a rejected token writes nothing', () async {
    final repo = buildRepo();

    await expectLater(
      repo.signInWithToken(instanceUrl: 'https://gitlab.com', token: 'wrong'),
      throwsA(isA<GitLabAuthException>()),
    );

    // A failed attempt must not leave a half-signed-in session behind.
    expect(accountStore.readActive(), isNull);
  });

  test('sign-out clears the account and the token', () async {
    final repo = buildRepo();
    final account = await repo.signInWithToken(
      instanceUrl: 'https://gitlab.com',
      token: goodToken,
    );

    await repo.signOut(account);

    expect(accountStore.readActive(), isNull);
    expect(await repo.tokenFor(account), isNull);
  });
}
