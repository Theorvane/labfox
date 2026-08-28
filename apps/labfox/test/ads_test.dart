import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/core/ads/ad_banner.dart';
import 'package:labfox/core/ads/ads_providers.dart';
import 'package:labfox/core/ads/interstitial_policy.dart';
import 'package:labfox/core/entitlement/entitlement.dart';
import 'package:labfox/core/entitlement/entitlement_providers.dart';

class _FixedEntitlement extends EntitlementController {
  _FixedEntitlement(this.value);

  final Entitlement value;

  @override
  Entitlement build() => value;
}

void main() {
  group('adsEnabledProvider', () {
    test('free users see ads', () {
      final container = ProviderContainer(
        overrides: [
          entitlementProvider.overrideWith(
            () => _FixedEntitlement(Entitlement.free),
          ),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(adsEnabledProvider), isTrue);
    });

    test('subscribers see no ads', () {
      final container = ProviderContainer(
        overrides: [
          entitlementProvider.overrideWith(
            () => _FixedEntitlement(Entitlement.subscribed),
          ),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(adsEnabledProvider), isFalse);
    });
  });

  group('InterstitialPolicy', () {
    test('shows every Nth transition after the warm-up, not before', () {
      var now = DateTime(2026, 1, 1, 12);
      final policy = InterstitialPolicy(
        every: 3,
        cooldown: const Duration(minutes: 2),
        clock: () => now,
      );

      // The first pass through the cycle never shows: warm-up.
      expect(policy.onTransition(), isFalse);
      expect(policy.onTransition(), isFalse);
      expect(policy.onTransition(), isTrue);

      // Cooldown holds even when the count comes around again.
      expect(policy.onTransition(), isFalse);
      expect(policy.onTransition(), isFalse);
      expect(policy.onTransition(), isFalse);

      // After the cooldown the cycle shows again.
      now = now.add(const Duration(minutes: 3));
      expect(policy.onTransition(), isTrue);
    });
  });

  group('AdBanner', () {
    Future<void> pump(WidgetTester tester, Entitlement entitlement) {
      return tester.pumpWidget(
        ProviderScope(
          overrides: [
            entitlementProvider.overrideWith(
              () => _FixedEntitlement(entitlement),
            ),
            bannerViewBuilderProvider.overrideWithValue(
              (context) => const SizedBox(
                key: Key('stub-banner'),
                width: 320,
                height: 50,
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: AdBanner())),
        ),
      );
    }

    testWidgets('renders the banner slot for free users', (tester) async {
      await pump(tester, Entitlement.free);
      expect(find.byKey(const Key('stub-banner')), findsOneWidget);
    });

    testWidgets('renders nothing for subscribers', (tester) async {
      await pump(tester, Entitlement.subscribed);
      expect(find.byKey(const Key('stub-banner')), findsNothing);
    });
  });
}
