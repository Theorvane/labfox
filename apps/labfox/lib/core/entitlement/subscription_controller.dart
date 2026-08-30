import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../analytics/analytics.dart';
import 'entitlement_providers.dart';
import 'store_entitlement_source.dart';

/// The subscription as the store describes it.
///
/// The price is whatever the store returned — already formatted in the user's
/// currency for their region. Never build one of these in the app: a
/// hardcoded price would be wrong everywhere outside one country, and wrong
/// everywhere the moment pricing changes.
class SubscriptionOffer {
  const SubscriptionOffer(this.product);

  final ProductDetails product;

  String get price => product.price;
  String get title => product.title;
  String get description => product.description;
}

/// What the store is willing to sell, or null when there is nothing to sell.
///
/// Null is a normal state, not an error: the product may not exist in the store
/// yet, the store may be unreachable, or this may be a platform that ships
/// everything free. The screen renders all of those the same way, because from
/// the user's side they are the same — there is nothing to buy right now.
final subscriptionOfferProvider = FutureProvider<SubscriptionOffer?>((
  ref,
) async {
  if (ref.watch(freePlatformProvider)) {
    return null;
  }
  final api = ref.watch(purchaseApiProvider);
  try {
    if (!await api.isAvailable()) {
      return null;
    }
    final response = await api.queryProductDetails({subscriptionProductId});
    final product = response.productDetails
        .where((p) => p.id == subscriptionProductId)
        .firstOrNull;
    return product == null ? null : SubscriptionOffer(product);
  } catch (_) {
    // A store that cannot answer is indistinguishable, to the user, from one
    // with nothing to sell. Surfacing an exception here would put an error on
    // a screen whose only honest message is "not available right now".
    return null;
  }
});

/// Drives the purchase and restore actions.
///
/// Both are fire-and-forget as far as entitlement goes: the store answers on
/// its purchase stream, which [EntitlementController] is what ultimately reads.
/// This only reports whether the request itself could be made.
class SubscriptionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Starts the store's purchase flow.
  ///
  /// Does nothing when there is no offer — there is no product to buy, and
  /// calling the store with a product it does not know throws.
  Future<void> subscribe() async {
    final offer = await ref.read(subscriptionOfferProvider.future);
    if (offer == null) {
      return;
    }
    unawaited(ref.read(analyticsProvider).track('subscription_started'));
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final started = await ref
          .read(purchaseApiProvider)
          .buyNonConsumable(
            purchaseParam: PurchaseParam(productDetails: offer.product),
          );
      if (!started) {
        throw StateError('The store rejected the purchase request.');
      }
      // The purchase itself arrives on the stream; re-read so entitlement
      // reflects it as soon as the store has spoken.
      await ref.read(entitlementProvider.notifier).refresh();
      // Whether the store said yes, which is what separates an abandoned
      // purchase sheet from a completed one.
      unawaited(
        ref.read(analyticsProvider).track('subscription_result', {
          'subscribed': ref.read(entitlementProvider).isSubscribed,
        }),
      );
    });
  }

  /// Re-reads what the user already owns.
  ///
  /// Apple requires this to be reachable from the UI (App Store Review
  /// Guideline 3.1.1), and it is what a user on a new device needs.
  Future<void> restore() async {
    unawaited(ref.read(analyticsProvider).track('subscription_restored'));
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(entitlementProvider.notifier).refresh(),
    );
  }
}

final subscriptionControllerProvider =
    AsyncNotifierProvider<SubscriptionController, void>(
      SubscriptionController.new,
    );
