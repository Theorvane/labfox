import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/auth/account_store.dart';
import 'package:labfox/core/auth/auth_repository.dart';
import 'package:labfox/core/auth/authorization_launcher.dart';
import 'package:labfox/core/auth/oauth_redirect.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_dio.dart';

/// Echoes back the redirect a real browser would produce.
class _FakeLauncher implements AuthorizationLauncher {
  _FakeLauncher({this.tamperState = false, this.error});

  static const code = 'the-code';
  final bool tamperState;
  final String? error;
  Uri? seenUrl;
  OAuthRedirect? seenRedirect;

  @override
  Future<Uri> authorize({
    required Uri url,
    required OAuthRedirect redirect,
  }) async {
    seenUrl = url;
    seenRedirect = redirect;
    final state = url.queryParameters['state']!;
    final query = <String, String>{};
    if (error != null) {
      query['error'] = error!;
    } else {
      query['code'] = code;
      query['state'] = tamperState ? 'tampered' : state;
    }
    return Uri.parse('labfox://oauth-callback').replace(queryParameters: query);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AccountStore accountStore;
  late CredentialStore credentialStore;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    accountStore = AccountStore(await SharedPreferences.getInstance());
    credentialStore = CredentialStore();
  });

  String? exchangeRedirectUri;

  AuthRepository buildRepo({
    required AuthorizationLauncher launcher,
    int Function()? now,
    int initialCreatedAt = 1000,
    int initialExpiresIn = 7200,
    OAuthRedirect redirect = const OAuthRedirect(
      redirectUri: 'labfox://oauth-callback',
      callbackScheme: 'labfox',
    ),
  }) {
    return AuthRepository(
      accountStore: accountStore,
      credentialStore: credentialStore,
      authorizationLauncher: launcher,
      oauthRedirect: redirect,
      nowEpochSeconds: now,
      oauthApi: OAuthApi(
        fakeDio((options) {
          final grant = (options.data as Map)['grant_type'];
          if (grant == 'authorization_code') {
            exchangeRedirectUri =
                (options.data as Map)['redirect_uri'] as String;
          }
          if (grant == 'refresh_token') {
            return (
              status: 200,
              body: {
                'access_token': 'access-refreshed',
                'refresh_token': 'refresh-2',
                'expires_in': 7200,
                'created_at': 9000,
              },
            );
          }
          return (
            status: 200,
            body: {
              'access_token': 'access-1',
              'refresh_token': 'refresh-1',
              'expires_in': initialExpiresIn,
              'created_at': initialCreatedAt,
            },
          );
        }),
      ),
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
              dio: fakeDio(
                (options) => (
                  status: 200,
                  body: {'id': 42, 'username': 'jungwon', 'name': 'Jungwon'},
                ),
              ),
            );
          },
    );
  }

  test('a successful OAuth flow persists an oauth account and token', () async {
    final launcher = _FakeLauncher();
    // Within the token's validity window (created 1000, lives 7200s), so no
    // refresh happens and the original access token is returned.
    final repo = buildRepo(launcher: launcher, now: () => 2000);

    final account = await repo.signInWithOAuth(
      instanceUrl: 'https://gitlab.com',
      clientId: 'app-1',
    );

    expect(account.user.username, 'jungwon');
    expect(account.authMethod, AuthMethod.oauth);
    expect(account.oauthClientId, 'app-1');
    expect(accountStore.readActive()?.user.id, 42);
    // The access token comes back for authenticating requests.
    expect(await repo.tokenFor(account), 'access-1');

    // The authorize URL carried a PKCE challenge and CSRF state.
    final q = launcher.seenUrl!.queryParameters;
    expect(q['code_challenge_method'], 'S256');
    expect(q['code_challenge'], isNotEmpty);
    expect(q['state'], isNotEmpty);
  });

  test('a mismatched state is rejected and writes nothing', () async {
    final repo = buildRepo(launcher: _FakeLauncher(tamperState: true));

    await expectLater(
      repo.signInWithOAuth(instanceUrl: 'https://gitlab.com', clientId: 'a'),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(accountStore.readActive(), isNull);
  });

  test('a denied authorization surfaces an auth error', () async {
    final repo = buildRepo(launcher: _FakeLauncher(error: 'access_denied'));

    await expectLater(
      repo.signInWithOAuth(instanceUrl: 'https://gitlab.com', clientId: 'a'),
      throwsA(isA<GitLabAuthException>()),
    );
  });

  test('tokenFor refreshes an expired OAuth token', () async {
    // Token was created at 1000 and lives 7200s, so it expires at 8200. Sign in
    // at that moment, then read the token well past expiry.
    var now = 1000;
    final repo = buildRepo(launcher: _FakeLauncher(), now: () => now);

    final account = await repo.signInWithOAuth(
      instanceUrl: 'https://gitlab.com',
      clientId: 'app-1',
    );
    expect(await repo.tokenFor(account), 'access-1');

    now = 9000; // past 8200 expiry
    expect(await repo.tokenFor(account), 'access-refreshed');

    // The refreshed token is persisted, so the next read does not refresh again.
    now = 9100;
    expect(await repo.tokenFor(account), 'access-refreshed');
  });

  test('threads a desktop loopback redirect through the flow', () async {
    final launcher = _FakeLauncher();
    final desktop = resolveOAuthRedirect(
      isDesktopLoopback: true,
      loopbackPort: 8620,
    );
    final repo = buildRepo(
      launcher: launcher,
      now: () => 2000,
      redirect: desktop,
    );

    await repo.signInWithOAuth(
      instanceUrl: 'https://gitlab.com',
      clientId: 'app-1',
    );

    // The loopback redirect reaches the authorize URL, the browser launch, and
    // the token exchange.
    expect(
      launcher.seenUrl!.queryParameters['redirect_uri'],
      'http://localhost:8620',
    );
    expect(launcher.seenRedirect!.useWebview, isFalse);
    expect(exchangeRedirectUri, 'http://localhost:8620');
  });
}
