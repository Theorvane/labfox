import 'dart:convert';

import 'package:gitlab_models/gitlab_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the connected accounts and which one is active, across restarts.
///
/// Only non-secret metadata lives here: each account's instance URL and user.
/// Tokens never touch this store — they stay in secure storage, keyed by the
/// same (host, user id) — so ordinary preferences hold no secret.
class AccountStore {
  AccountStore(this._prefs);

  final SharedPreferences _prefs;

  static const _accountsKey = 'labfox.accounts';
  static const _activeIdKey = 'labfox.active_account_id';

  /// All connected accounts, in the order they were added.
  List<Account> readAccounts() {
    final raw = _prefs.getStringList(_accountsKey) ?? const [];
    return raw
        .map((s) => Account.fromJson(json.decode(s) as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// The active account, or null when signed out.
  Account? readActive() {
    final id = _prefs.getString(_activeIdKey);
    if (id == null) {
      return null;
    }
    for (final account in readAccounts()) {
      if (account.id == id) {
        return account;
      }
    }
    return null;
  }

  /// Adds an account (or updates it if already present) and makes it active.
  Future<void> add(Account account) async {
    final accounts = readAccounts().where((a) => a.id != account.id).toList()
      ..add(account);
    await _writeAccounts(accounts);
    await _prefs.setString(_activeIdKey, account.id);
  }

  /// Switches the active account. The account must already be in the store.
  Future<void> setActive(Account account) async {
    await _prefs.setString(_activeIdKey, account.id);
  }

  /// Removes an account. If it was active, the active account falls back to the
  /// first remaining one, or signed out when none remain.
  Future<void> remove(Account account) async {
    final remaining = readAccounts().where((a) => a.id != account.id).toList();
    await _writeAccounts(remaining);
    if (readActive()?.id == account.id || readActive() == null) {
      if (remaining.isEmpty) {
        await _prefs.remove(_activeIdKey);
      } else {
        await _prefs.setString(_activeIdKey, remaining.first.id);
      }
    }
  }

  Future<void> _writeAccounts(List<Account> accounts) {
    return _prefs.setStringList(
      _accountsKey,
      accounts.map((a) => json.encode(a.toJson())).toList(),
    );
  }
}
