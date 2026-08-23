import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:labfox/core/auth/auth_providers.dart';
import 'package:labfox/core/entitlement/entitlement_providers.dart';
import 'package:labfox/core/entitlement/store_entitlement_source.dart';
import 'package:labfox/core/entitlement/subscription_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

ProductDetails _product({String id = subscriptionProductId}) => ProductDetails(
  id: id,
  title: 'LabFox',
  description: 'Everything unlocked',
  price: '₩4,900',
  rawPrice: 4900,
  currencyCode: 'KRW',
);

class _FakePurchaseApi implements PurchaseApi {
  final _controller = StreamController<List<PurchaseDetails>>.broadcast();

  bool available = true;
  List<ProductDetails> products = [];
  Set<String> notFound = {};
  int buyCalls = 0;
  int restoreCalls = 0;
  Object? queryError;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _controller.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> restorePurchases() async => restoreCalls++;

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids) async {
    if (queryError != null) {
      throw queryError!;
    }
    return ProductDetailsResponse(
      productDetails: products,
      notFoundIDs: notFound.toList(),
    );
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    buyCalls++;
    return true;
  }

  Future<void> dispose() => _controller.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakePurchaseApi api;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    api = _FakePurchaseApi();
    addTearDown(api.dispose);
  });

  ProviderContainer containerWith({bool isFreePlatform = false}) {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        freePlatformProvider.overrideWithValue(isFreePlatform),
        purchaseApiProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('the price comes from the store, never from the app', () async {
    api.products = [_product()];
    final container = containerWith();

    final offer = await container.read(subscriptionOfferProvider.future);

    expect(offer, isNotNull);
    expect(offer!.price, '₩4,900');
  });

  test('a product missing from the store yields no offer', () async {
    api.notFound = {subscriptionProductId};
    final container = containerWith();

    // This is the state until the products exist in App Store Connect and Play
    // Console, so the screen has to render it rather than crash or show a
    // buy button that cannot work.
    expect(await container.read(subscriptionOfferProvider.future), isNull);
  });

  test('an unavailable store yields no offer', () async {
    api.available = false;
    final container = containerWith();

    expect(await container.read(subscriptionOfferProvider.future), isNull);
  });

  test(
    'a store that fails the query yields no offer rather than throwing',
    () async {
      api.queryError = Exception('network');
      final container = containerWith();

      expect(await container.read(subscriptionOfferProvider.future), isNull);
    },
  );

  test('a free platform is never offered a subscription', () async {
    api.products = [_product()];
    final container = containerWith(isFreePlatform: true);

    // Windows and macOS ship with every feature; offering to sell it would be
    // charging for something the user already has.
    expect(await container.read(subscriptionOfferProvider.future), isNull);
  });

  test('subscribing hands the store product to the store', () async {
    api.products = [_product()];
    final container = containerWith();
    await container.read(subscriptionOfferProvider.future);

    await container.read(subscriptionControllerProvider.notifier).subscribe();

    expect(api.buyCalls, 1);
  });

  test('subscribing without an offer does not call the store', () async {
    api.notFound = {subscriptionProductId};
    final container = containerWith();
    await container.read(subscriptionOfferProvider.future);

    await container.read(subscriptionControllerProvider.notifier).subscribe();

    expect(api.buyCalls, 0);
  });

  test('restore asks the store and refreshes entitlement', () async {
    final container = containerWith();

    await container.read(subscriptionControllerProvider.notifier).restore();

    expect(api.restoreCalls, greaterThanOrEqualTo(1));
  });
}
