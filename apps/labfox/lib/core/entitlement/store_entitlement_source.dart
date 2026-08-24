import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import 'entitlement.dart';

/// The store product backing the subscription.
///
/// Overridable at build time so a sandbox or a renamed product does not need a
/// code change: `--dart-define=LABFOX_SUBSCRIPTION_ID=...`.
const subscriptionProductId = String.fromEnvironment(
  'LABFOX_SUBSCRIPTION_ID',
  defaultValue: 'labfox_subscription',
);

/// Raised when the store cannot be reached or is not available on this device.
///
/// Deliberately not "not subscribed": the two mean different things, and
/// collapsing them would downgrade a paying user whenever a network call fails.
class StoreUnavailableException implements Exception {
  const StoreUnavailableException();

  @override
  String toString() => 'StoreUnavailableException';
}

/// The slice of `in_app_purchase` this app uses.
///
/// The plugin exposes a singleton, which cannot be substituted in a test, so
/// the app depends on this instead. [LivePurchaseApi] is the real one.
abstract class PurchaseApi {
  Stream<List<PurchaseDetails>> get purchaseStream;

  Future<bool> isAvailable();

  Future<void> restorePurchases();

  Future<void> completePurchase(PurchaseDetails purchase);

  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids);

  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam});
}

/// [PurchaseApi] backed by the plugin — StoreKit on Apple, Play Billing on
/// Android.
class LivePurchaseApi implements PurchaseApi {
  LivePurchaseApi([InAppPurchase? purchases])
    : _purchases = purchases ?? InAppPurchase.instance;

  final InAppPurchase _purchases;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _purchases.purchaseStream;

  @override
  Future<bool> isAvailable() => _purchases.isAvailable();

  @override
  Future<void> restorePurchases() => _purchases.restorePurchases();

  @override
  Future<void> completePurchase(PurchaseDetails purchase) =>
      _purchases.completePurchase(purchase);

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids) =>
      _purchases.queryProductDetails(ids);

  /// Auto-renewing subscriptions go through the non-consumable call on both
  /// platforms; the plugin has no separate subscription entry point.
  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) =>
      _purchases.buyNonConsumable(purchaseParam: purchaseParam);
}

/// Entitlement as the store reports it.
///
/// Both stores deliver purchases and restores on a stream rather than in reply
/// to a request, so this holds the latest answer the stream has given and
/// [read] re-asks the store before returning it.
class StoreEntitlementSource implements EntitlementSource {
  StoreEntitlementSource(
    this._api, {
    Duration settle = const Duration(seconds: 5),
  }) : _settle = settle {
    _subscription = _api.purchaseStream.listen(_onPurchases);
  }

  final PurchaseApi _api;
  late final StreamSubscription<List<PurchaseDetails>> _subscription;

  Entitlement _latest = Entitlement.free;

  /// How long to wait for the store to answer a restore before returning what
  /// is already known. A store with nothing to restore may say nothing at all,
  /// so this cannot wait indefinitely. Injectable so tests do not spend it.
  final Duration _settle;

  Completer<void>? _pending;

  @override
  Future<Entitlement> read() async {
    if (!await _api.isAvailable()) {
      throw const StoreUnavailableException();
    }
    final pending = _pending = Completer<void>();
    try {
      await _api.restorePurchases();
    } catch (_) {
      _pending = null;
      throw const StoreUnavailableException();
    }
    // Either the stream answers, or nothing was owned and it stays silent.
    await pending.future.timeout(_settle, onTimeout: () {});
    _pending = null;
    return _latest;
  }

  void _onPurchases(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID != subscriptionProductId) {
        continue;
      }
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _latest = Entitlement.subscribed;
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          _latest = Entitlement.free;
        case PurchaseStatus.pending:
          // Not yet owned; leave the current answer alone.
          break;
      }
      // Both stores refund a purchase that is never acknowledged, so this is
      // not optional bookkeeping.
      if (purchase.pendingCompletePurchase) {
        unawaited(_api.completePurchase(purchase));
      }
    }
    if (_pending != null && !_pending!.isCompleted) {
      _pending!.complete();
    }
  }

  Future<void> dispose() => _subscription.cancel();
}
