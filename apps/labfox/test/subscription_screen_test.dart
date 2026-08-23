import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:labfox/core/auth/auth_providers.dart';
import 'package:labfox/core/entitlement/entitlement_providers.dart';
import 'package:labfox/core/entitlement/store_entitlement_source.dart';
import 'package:labfox/features/settings/presentation/subscription_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePurchaseApi implements PurchaseApi {
  final _controller = StreamController<List<PurchaseDetails>>.broadcast();

  List<ProductDetails> products = [];
  int buyCalls = 0;
  int restoreCalls = 0;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _controller.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> restorePurchases() async => restoreCalls++;

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids) async =>
      ProductDetailsResponse(productDetails: products, notFoundIDs: const []);

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    buyCalls++;
    return true;
  }

  Future<void> dispose() => _controller.close();
}

void main() {
  late _FakePurchaseApi api;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    api = _FakePurchaseApi();
    addTearDown(api.dispose);
  });

  Future<void> pump(WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          freePlatformProvider.overrideWithValue(false),
          purchaseApiProvider.overrideWithValue(api),
          // The real adapter waits five seconds for a store that owns nothing
          // to answer. That timer would outlive the test, so shorten it.
          entitlementSourceProvider.overrideWith(
            (ref) => StoreEntitlementSource(
              api,
              settle: const Duration(milliseconds: 10),
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SubscriptionScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the price exactly as the store formatted it', (
    tester,
  ) async {
    api.products = [
      ProductDetails(
        id: subscriptionProductId,
        title: 'LabFox',
        description: '',
        // Already localised by the store — currency, separators and all.
        price: '₩4,900',
        rawPrice: 4900,
        currencyCode: 'KRW',
      ),
    ];

    await pump(tester);

    expect(find.textContaining('₩4,900'), findsOneWidget);
  });

  testWidgets('says so plainly when the store has nothing to sell', (
    tester,
  ) async {
    // This is the live state until the products exist in App Store Connect and
    // Play Console, so it has to read as an explanation rather than a bug.
    await pump(tester);

    expect(
      find.text('The store is not available right now. Try again later.'),
      findsOneWidget,
    );
    expect(find.textContaining('Subscribe for'), findsNothing);
  });

  testWidgets('always offers restore, which Apple requires', (tester) async {
    await pump(tester);

    // Guideline 3.1.1: the control must be reachable even with no offer to buy.
    await tester.tap(find.text('Restore purchases'));
    await tester.pumpAndSettle();

    expect(api.restoreCalls, greaterThanOrEqualTo(1));
  });

  testWidgets('subscribing starts the store flow', (tester) async {
    api.products = [
      ProductDetails(
        id: subscriptionProductId,
        title: 'LabFox',
        description: '',
        price: r'US$4.99',
        rawPrice: 4.99,
        currencyCode: 'USD',
      ),
    ];
    await pump(tester);

    await tester.tap(find.textContaining('Subscribe for'));
    await tester.pumpAndSettle();

    expect(api.buyCalls, 1);
  });
}
