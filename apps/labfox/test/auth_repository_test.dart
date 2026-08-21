import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/auth/account_store.dart';
import 'package:labfox/core/auth/auth_repository.dart';
import 'package:labfox/core/storage/local_projects_store.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_dio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AccountStore accountStore;
  late CredentialStore credentialStore;
  late LocalProjectsStore projectsStore;

  // A token is valid only when it equals this; anything else 401s, the way a
  // real instance rejects a bad token.
  const goodToken = 'glpat-valid';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    accountStore = AccountStore(prefs);
    credentialStore = CredentialStore();
    projectsStore = LocalProjectsStore(prefs);
  });

  AuthRepository buildRepo() {
    return AuthRepository(
      accountStore: accountStore,
      credentialStore: credentialStore,
      projectsStore: projectsStore,
      clientFactory:
          ({
            required String baseUrl,
            required String token,
            bool bearer = false,
          }) {
            return GitLabClient(
              baseUrl: baseUrl,
              token: token,
              bearer: bearer,
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

  test('sign-out clears the account\'s recents and favorites', () async {
    final repo = buildRepo();
    final account = await repo.signInWithToken(
      instanceUrl: 'https://gitlab.com',
      token: goodToken,
    );
    const project = Project(
      id: 7,
      name: 'internal-tools',
      pathWithNamespace: 'acme/internal-tools',
    );
    await projectsStore.recordRecent(account.id, project);
    await projectsStore.toggleFavorite(account.id, project);

    await repo.signOut(account);

    // These carry real project names and ids. Leaving them behind would expose
    // the removed account's projects to whoever uses the device next, and the
    // shipped privacy policy promises they go.
    expect(projectsStore.readRecents(account.id), isEmpty);
    expect(projectsStore.readFavorites(account.id), isEmpty);
  });
}
