import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:labfox/core/entitlement/entitlement.dart';
import 'package:labfox/core/entitlement/store_entitlement_source.dart';

PurchaseDetails _purchase(
  PurchaseStatus status, {
  String productId = subscriptionProductId,
}) {
  return PurchaseDetails(
    purchaseID: 'p1',
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: '',
      serverVerificationData: '',
      source: 'test',
    ),
    transactionDate: null,
    status: status,
  );
}

/// Stands in for the plugin so the mapping can be exercised without a store.
class _FakePurchaseApi implements PurchaseApi {
  final _controller = StreamController<List<PurchaseDetails>>.broadcast();
  final List<PurchaseDetails> completed = [];
  bool available = true;
  int restoreCalls = 0;

  void emit(List<PurchaseDetails> purchases) => _controller.add(purchases);

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _controller.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> restorePurchases() async => restoreCalls++;

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async =>
      completed.add(purchase);

  Future<void> dispose() => _controller.close();
}

void main() {
  late _FakePurchaseApi api;
  late StoreEntitlementSource source;

  setUp(() {
    api = _FakePurchaseApi();
    // A real store gets five seconds; the fake answers instantly, so waiting
    // for that here would only slow CI down.
    source = StoreEntitlementSource(
      api,
      settle: const Duration(milliseconds: 10),
    );
    addTearDown(source.dispose);
    addTearDown(api.dispose);
  });

  test('a purchased subscription entitles', () async {
    api.emit([_purchase(PurchaseStatus.purchased)]);
    await pumpEventQueue();

    expect(await source.read(), Entitlement.subscribed);
  });

  test('a restored subscription entitles', () async {
    api.emit([_purchase(PurchaseStatus.restored)]);
    await pumpEventQueue();

    expect(await source.read(), Entitlement.subscribed);
  });

  test('a pending purchase does not entitle until it completes', () async {
    api.emit([_purchase(PurchaseStatus.pending)]);
    await pumpEventQueue();
    expect(await source.read(), Entitlement.free);

    api.emit([_purchase(PurchaseStatus.purchased)]);
    await pumpEventQueue();
    expect(await source.read(), Entitlement.subscribed);
  });

  test('a failed or cancelled purchase does not entitle', () async {
    api.emit([_purchase(PurchaseStatus.error)]);
    await pumpEventQueue();
    expect(await source.read(), Entitlement.free);

    api.emit([_purchase(PurchaseStatus.canceled)]);
    await pumpEventQueue();
    expect(await source.read(), Entitlement.free);
  });

  test('another product does not entitle', () async {
    api.emit([
      _purchase(PurchaseStatus.purchased, productId: 'something_else'),
    ]);
    await pumpEventQueue();

    expect(await source.read(), Entitlement.free);
  });

  test('every delivered purchase is completed, as both stores require', () async {
    final purchase = _purchase(PurchaseStatus.purchased)
      ..pendingCompletePurchase = true;
    api.emit([purchase]);
    await pumpEventQueue();

    // An uncompleted purchase is refunded by Apple and refunded or cancelled by
    // Google, so this is not optional bookkeeping.
    expect(api.completed, [purchase]);
  });

  test('a purchase needing no completion is left alone', () async {
    final purchase = _purchase(PurchaseStatus.purchased);
    api.emit([purchase]);
    await pumpEventQueue();

    expect(api.completed, isEmpty);
  });

  test('read asks the store to re-report what the user owns', () async {
    await source.read();

    expect(api.restoreCalls, 1);
  });

  test('an unavailable store reports unknown rather than free', () async {
    api.available = false;

    // Throwing is what keeps a subscriber entitled: the controller treats an
    // unreachable store as "no new information" and keeps the cached answer,
    // where returning free would silently downgrade a paying user.
    await expectLater(source.read(), throwsA(isA<StoreUnavailableException>()));
  });
}
