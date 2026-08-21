import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:secure_storage/secure_storage.dart';

import '../storage/local_projects_store.dart';
import 'account_store.dart';
import 'authorization_launcher.dart';
import 'oauth_config.dart';
import 'oauth_redirect.dart';

/// The client factory signature. [bearer] selects OAuth (`Authorization:
/// Bearer`) over a PAT (`PRIVATE-TOKEN`).
typedef ClientFactory =
    GitLabClient Function({
      required String baseUrl,
      required String token,
      bool bearer,
    });

/// Signs accounts in and out, and owns where the token and account metadata go.
///
/// The token goes to secure storage; the account metadata goes to the account
/// store. Callers above this never see the token — they get an [Account].
class AuthRepository {
  AuthRepository({
    required AccountStore accountStore,
    required CredentialStore credentialStore,
    required LocalProjectsStore projectsStore,
    OAuthApi? oauthApi,
    AuthorizationLauncher authorizationLauncher = const WebAuthLauncher(),
    OAuthRedirect oauthRedirect = const OAuthRedirect(
      redirectUri: OAuthConfig.redirectUri,
      callbackScheme: OAuthConfig.callbackScheme,
    ),
    ClientFactory? clientFactory,
    int Function()? nowEpochSeconds,
    Random? random,
  }) : _accountStore = accountStore,
       _credentialStore = credentialStore,
       _projectsStore = projectsStore,
       _oauthApi = oauthApi ?? OAuthApi(Dio()),
       _launcher = authorizationLauncher,
       _redirect = oauthRedirect,
       _clientFactory = clientFactory ?? _defaultClientFactory,
       _now = nowEpochSeconds ?? _systemNow,
       _random = random ?? Random.secure();

  final AccountStore _accountStore;
  final CredentialStore _credentialStore;
  final LocalProjectsStore _projectsStore;
  final OAuthApi _oauthApi;
  final AuthorizationLauncher _launcher;
  final OAuthRedirect _redirect;
  final ClientFactory _clientFactory;
  final int Function() _now;
  final Random _random;

  /// The credential kind for the OAuth token set. The whole [OAuthToken] JSON
  /// (access, refresh, and expiry) is stored here; the refresh token is secret,
  /// so it stays in secure storage with the rest.
  static const _oauthKind = 'oauth_access';

  static const _patKind = 'pat';

  static int _systemNow() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  static GitLabClient _defaultClientFactory({
    required String baseUrl,
    required String token,
    bool bearer = false,
  }) => GitLabClient(baseUrl: baseUrl, token: token, bearer: bearer);

  /// The active account, or null.
  Account? currentAccount() => _accountStore.readActive();

  /// All connected accounts.
  List<Account> accounts() => _accountStore.readAccounts();

  /// Switches the active account. It must already be connected.
  Future<void> switchTo(Account account) => _accountStore.setActive(account);

  /// Validates a token against an instance, then persists the session.
  ///
  /// Validation is a `GET /user`: it proves the token works and yields the user
  /// in one call. Only after it succeeds is anything written, so a bad attempt
  /// leaves no half-signed-in state behind.
  Future<Account> signInWithToken({
    required String instanceUrl,
    required String token,
  }) async {
    final client = _clientFactory(baseUrl: instanceUrl, token: token);
    try {
      final user = await client.users.current();
      final account = Account(instanceUrl: instanceUrl, user: user);

      await _credentialStore.writeToken(
        instanceUrl: instanceUrl,
        userId: user.id,
        kind: _patKind,
        token: token,
      );
      await _accountStore.add(account);

      return account;
    } finally {
      client.close();
    }
  }

  /// Runs the OAuth Authorization Code + PKCE flow, then persists the session.
  ///
  /// The browser is opened through [AuthorizationLauncher]; the CSRF `state` and
  /// PKCE verifier are checked before the code is exchanged. Nothing is written
  /// until `GET /user` confirms the token, so a cancelled or tampered flow
  /// leaves no account behind.
  Future<Account> signInWithOAuth({
    required String instanceUrl,
    required String clientId,
  }) async {
    final pkce = Pkce.generate(random: _random);
    final state = _newState();
    final url = OAuthApi.authorizationUrl(
      instanceUrl: instanceUrl,
      clientId: clientId,
      redirectUri: _redirect.redirectUri,
      state: state,
      codeChallenge: pkce.challenge,
      scope: OAuthConfig.scope,
    );

    final redirect = await _launcher.authorize(url: url, redirect: _redirect);
    final params = redirect.queryParameters;
    if (params['error'] != null) {
      throw const GitLabAuthException('Authorization was denied.');
    }
    if (params['state'] != state) {
      throw const GitLabAuthException(
        'The sign-in response failed a security check.',
      );
    }
    final code = params['code'];
    if (code == null || code.isEmpty) {
      throw const GitLabAuthException('No authorization code was returned.');
    }

    final token = await _oauthApi.exchangeCode(
      instanceUrl: instanceUrl,
      clientId: clientId,
      code: code,
      redirectUri: _redirect.redirectUri,
      codeVerifier: pkce.verifier,
    );

    final client = _clientFactory(
      baseUrl: instanceUrl,
      token: token.accessToken,
      bearer: true,
    );
    try {
      final user = await client.users.current();
      final account = Account(
        instanceUrl: instanceUrl,
        user: user,
        authMethod: AuthMethod.oauth,
        oauthClientId: clientId,
      );

      await _writeOAuthToken(account, token);
      await _accountStore.add(account);

      return account;
    } finally {
      client.close();
    }
  }

  /// The access token to authenticate [account]'s requests.
  ///
  /// For OAuth accounts the stored token is refreshed first when it is expired
  /// (or within a minute of it), so a request does not fail mid-flight on a
  /// stale token.
  Future<String?> tokenFor(Account account) async {
    if (account.authMethod == AuthMethod.pat) {
      return _credentialStore.readToken(
        instanceUrl: account.instanceUrl,
        userId: account.user.id,
        kind: _patKind,
      );
    }

    final raw = await _credentialStore.readToken(
      instanceUrl: account.instanceUrl,
      userId: account.user.id,
      kind: _oauthKind,
    );
    if (raw == null) {
      return null;
    }
    var token = OAuthToken.fromJson(json.decode(raw) as Map<String, dynamic>);
    final refreshToken = token.refreshToken;
    final clientId = account.oauthClientId;
    if (token.isExpiredAt(_now(), leewaySeconds: 60) &&
        refreshToken != null &&
        clientId != null) {
      token = await _oauthApi.refresh(
        instanceUrl: account.instanceUrl,
        clientId: clientId,
        refreshToken: refreshToken,
      );
      await _writeOAuthToken(account, token);
    }
    return token.accessToken;
  }

  /// Forces an OAuth token refresh, ignoring local expiry, and returns the new
  /// access token (or null when it cannot be refreshed).
  ///
  /// Used when the server rejects a token the client still believed valid — the
  /// server is the authority, so a 401 triggers this rather than trusting the
  /// stored expiry.
  Future<String?> refreshOAuthAccessToken(Account account) async {
    if (account.authMethod != AuthMethod.oauth) {
      return null;
    }
    final raw = await _credentialStore.readToken(
      instanceUrl: account.instanceUrl,
      userId: account.user.id,
      kind: _oauthKind,
    );
    if (raw == null) {
      return null;
    }
    final token = OAuthToken.fromJson(json.decode(raw) as Map<String, dynamic>);
    final refreshToken = token.refreshToken;
    final clientId = account.oauthClientId;
    if (refreshToken == null || clientId == null) {
      return null;
    }
    final fresh = await _oauthApi.refresh(
      instanceUrl: account.instanceUrl,
      clientId: clientId,
      refreshToken: refreshToken,
    );
    await _writeOAuthToken(account, fresh);
    return fresh.accessToken;
  }

  /// Removes an account: clears its token and drops it from the store. If it was
  /// active, the store falls back to another account or to signed out.
  Future<void> signOut(Account account) async {
    await _credentialStore.deleteAccount(
      instanceUrl: account.instanceUrl,
      userId: account.user.id,
    );
    // Recents and favorites hold real project names, ids, and paths for this
    // account. They are not secret, but they are the removed account's data, so
    // they go with it rather than waiting for the next person to use the device.
    await _projectsStore.clearAccount(account.id);
    await _accountStore.remove(account);
  }

  Future<void> _writeOAuthToken(Account account, OAuthToken token) {
    return _credentialStore.writeToken(
      instanceUrl: account.instanceUrl,
      userId: account.user.id,
      kind: _oauthKind,
      token: json.encode(token.toJson()),
    );
  }

  String _newState() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}
