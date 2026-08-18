import 'dart:convert';

import 'package:gitlab_models/gitlab_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists which account is active, across restarts.
///
/// Only non-secret metadata lives here: the instance URL and the user. The
/// token is never written here — it stays in secure storage, so this can use
/// ordinary preferences without holding a secret.
class AccountStore {
  AccountStore(this._prefs);

  final SharedPreferences _prefs;

  static const _activeAccountKey = 'labfox.active_account';

  Account? readActive() {
    final raw = _prefs.getString(_activeAccountKey);
    if (raw == null) {
      return null;
    }
    return Account.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  Future<void> writeActive(Account account) {
    return _prefs.setString(_activeAccountKey, json.encode(account.toJson()));
  }

  Future<void> clear() => _prefs.remove(_activeAccountKey);
}
