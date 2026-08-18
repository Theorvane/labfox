import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:secure_storage/secure_storage.dart';

import 'account_store.dart';

/// Signs accounts in and out, and owns where the token and account metadata go.
///
/// The token goes to secure storage; the account metadata goes to the account
/// store. Callers above this never see the token — they get an [Account].
class AuthRepository {
  AuthRepository({
    required AccountStore accountStore,
    required CredentialStore credentialStore,
    GitLabClient Function({required String baseUrl, required String token})?
    clientFactory,
  }) : _accountStore = accountStore,
       _credentialStore = credentialStore,
       _clientFactory = clientFactory ?? _defaultClientFactory;

  final AccountStore _accountStore;
  final CredentialStore _credentialStore;
  final GitLabClient Function({required String baseUrl, required String token})
  _clientFactory;

  static GitLabClient _defaultClientFactory({
    required String baseUrl,
    required String token,
  }) => GitLabClient(baseUrl: baseUrl, token: token);

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
        kind: 'pat',
        token: token,
      );
      await _accountStore.add(account);

      return account;
    } finally {
      client.close();
    }
  }

  Future<String?> tokenFor(Account account) {
    return _credentialStore.readToken(
      instanceUrl: account.instanceUrl,
      userId: account.user.id,
      kind: 'pat',
    );
  }

  /// Removes an account: clears its token and drops it from the store. If it was
  /// active, the store falls back to another account or to signed out.
  Future<void> signOut(Account account) async {
    await _credentialStore.deleteAccount(
      instanceUrl: account.instanceUrl,
      userId: account.user.id,
    );
    await _accountStore.remove(account);
  }
}
