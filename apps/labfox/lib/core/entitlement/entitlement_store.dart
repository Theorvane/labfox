import 'package:shared_preferences/shared_preferences.dart';

import 'entitlement.dart';

const _entitlementKey = 'entitlement';

/// Remembers the last entitlement the store reported.
///
/// This is what makes the app usable without a network round trip at launch,
/// and what a failed receipt check falls back to. It holds no receipt, no
/// token, and no identifier — only which of two states was last seen — so it
/// belongs in preferences rather than secure storage (AGENTS §7).
class EntitlementStore {
  EntitlementStore(this._prefs);

  final SharedPreferences _prefs;

  /// The last known entitlement, or null when the app has never seen an
  /// answer. Null is not the same as [Entitlement.free]: it means "never
  /// asked", which is why it is preserved rather than defaulted here.
  Entitlement? read() {
    return switch (_prefs.getString(_entitlementKey)) {
      'subscribed' => Entitlement.subscribed,
      'free' => Entitlement.free,
      _ => null,
    };
  }

  Future<void> write(Entitlement entitlement) =>
      _prefs.setString(_entitlementKey, entitlement.name);
}
