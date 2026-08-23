/// What the user is entitled to.
///
/// One subscription, so there are only two answers. See
/// `.agents/docs/monetization.md` for what each one unlocks.
enum Entitlement {
  free,
  subscribed;

  bool get isSubscribed => this == Entitlement.subscribed;
}

/// Where a subscription state comes from.
///
/// Implemented by the store adapters — StoreKit on Apple, Play Billing on
/// Android. Kept as an interface so the gates can be built and tested without
/// a store, and so neither store's SDK leaks into the rest of the app.
abstract class EntitlementSource {
  /// The current entitlement according to the store.
  ///
  /// Throws when the store cannot be reached. Callers must treat that as
  /// "unknown", never as "not entitled" — see [EntitlementStore].
  Future<Entitlement> read();
}
