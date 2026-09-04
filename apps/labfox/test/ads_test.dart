import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/core/ads/ad_banner.dart';
import 'package:labfox/core/ads/ads_providers.dart';
import 'package:labfox/core/ads/banner_retry.dart';
import 'package:labfox/core/ads/interstitial_policy.dart';
import 'package:labfox/core/entitlement/entitlement.dart';
import 'package:labfox/core/entitlement/entitlement_providers.dart';

class _CountingPolicy extends InterstitialPolicy {
  _CountingPolicy(this.onCall);

  final void Function() onCall;

  @override
  bool onTransition() {
    onCall();
    return false;
  }
}

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
    Future<void> pump(
      WidgetTester tester,
      Entitlement entitlement, {
      Future<bool>? initialized,
      void Function(BannerViewCallbacks callbacks)? onBannerCallbacks,
    }) {
      return tester.pumpWidget(
        ProviderScope(
          overrides: [
            entitlementProvider.overrideWith(
              () => _FixedEntitlement(entitlement),
            ),
            adsInitializerProvider.overrideWith(
              (ref) => initialized ?? Future.value(true),
            ),
            bannerViewBuilderProvider.overrideWithValue((context, callbacks) {
              onBannerCallbacks?.call(callbacks);
              return const SizedBox(
                key: Key('stub-banner'),
                width: 320,
                height: 50,
              );
            }),
          ],
          child: const MaterialApp(home: Scaffold(body: AdBanner())),
        ),
      );
    }

    // The slot costs nothing until an ad arrives, and keeps its space
    // afterwards: banners refresh on their own, and a refresh that fails
    // leaves the creative already on screen, so collapsing would hide a live
    // ad and pull the content out from under whoever was reading it. There is
    // deliberately no callback that can take the space back.
    testWidgets('keeps the banner slot collapsed until an ad loads', (
      tester,
    ) async {
      BannerViewCallbacks? callbacks;
      await pump(
        tester,
        Entitlement.free,
        onBannerCallbacks: (value) => callbacks = value,
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('stub-banner')), findsNothing);

      callbacks!.onLoaded();
      await tester.pump();
      expect(find.byKey(const Key('stub-banner')), findsOneWidget);
    });

    testWidgets('renders nothing for subscribers', (tester) async {
      await pump(tester, Entitlement.subscribed);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('stub-banner')), findsNothing);
    });

    // The banner view loads as soon as its platform view exists, so mounting
    // it before the SDK is up spends the one load attempt on a call the SDK
    // rejects, and the slot stays empty for the whole session.
    testWidgets('waits for the SDK before mounting the banner', (tester) async {
      final init = Completer<bool>();
      BannerViewCallbacks? callbacks;
      await pump(
        tester,
        Entitlement.free,
        initialized: init.future,
        onBannerCallbacks: (value) => callbacks = value,
      );
      await tester.pump();

      expect(find.byKey(const Key('stub-banner')), findsNothing);

      init.complete(true);
      await tester.pumpAndSettle();

      expect(callbacks, isNotNull);
      callbacks!.onLoaded();
      await tester.pump();
      expect(find.byKey(const Key('stub-banner')), findsOneWidget);
    });

    testWidgets('stays empty when the SDK never came up', (tester) async {
      await pump(tester, Entitlement.free, initialized: Future.value(false));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('stub-banner')), findsNothing);
    });
  });

  group('adsInitializerProvider', () {
    ProviderContainer container({
      required List<bool> attempts,
      required List<int> calls,
      List<String>? order,
    }) {
      var i = 0;
      final c = ProviderContainer(
        overrides: [
          entitlementProvider.overrideWith(
            () => _FixedEntitlement(Entitlement.free),
          ),
          adsPlatformProvider.overrideWithValue(true),
          adsInitBackoffProvider.overrideWithValue(const [Duration.zero]),
          trackingAuthorizationProvider.overrideWithValue(() async {
            order?.add('ask');
            return true;
          }),
          adsInitAttemptProvider.overrideWithValue(() async {
            order?.add('init');
            calls.add(++i);
            return attempts[i - 1];
          }),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    // A first launch that loses DNS fails init, and nothing else ever asks:
    // without a retry the slot is dead for the rest of the session.
    test('retries an init that failed', () async {
      final calls = <int>[];
      final c = container(attempts: [false, true], calls: calls);

      await expectLater(
        c.read(adsInitializerProvider.future),
        completion(isTrue),
      );
      expect(calls.length, 2);
    });

    test('gives up rather than retrying forever', () async {
      final calls = <int>[];
      final c = container(attempts: [false, false], calls: calls);

      await expectLater(
        c.read(adsInitializerProvider.future),
        completion(isFalse),
      );
      expect(calls.length, 2);
    });

    // Guideline 5.1.2(i): permission comes before the tracking, not after it.
    // Asking once the SDK is already up is the same rejection with extra steps.
    test('asks for tracking permission before starting the SDK', () async {
      final order = <String>[];
      final c = container(attempts: [true], calls: [], order: order);

      await c.read(adsInitializerProvider.future);

      expect(order, ['ask', 'init']);
    });

    // An app launched into the background can never show the prompt. Starting
    // the SDK then would track someone who was never asked.
    test('does not start the SDK when the prompt could not be shown', () async {
      final calls = <int>[];
      final c = ProviderContainer(
        overrides: [
          entitlementProvider.overrideWith(
            () => _FixedEntitlement(Entitlement.free),
          ),
          adsPlatformProvider.overrideWithValue(true),
          trackingAuthorizationProvider.overrideWithValue(() async => false),
          adsInitAttemptProvider.overrideWithValue(() async {
            calls.add(1);
            return true;
          }),
        ],
      );
      addTearDown(c.dispose);

      await expectLater(
        c.read(adsInitializerProvider.future),
        completion(isFalse),
      );
      expect(calls, isEmpty);
    });

    test('never asks a subscriber, who is not tracked', () async {
      final asked = <String>[];
      final c = ProviderContainer(
        overrides: [
          entitlementProvider.overrideWith(
            () => _FixedEntitlement(Entitlement.subscribed),
          ),
          adsPlatformProvider.overrideWithValue(true),
          trackingAuthorizationProvider.overrideWithValue(() async {
            asked.add('ask');
            return true;
          }),
        ],
      );
      addTearDown(c.dispose);

      await c.read(adsInitializerProvider.future);

      expect(asked, isEmpty);
    });

    test('does not touch the SDK for a subscriber', () async {
      final calls = <int>[];
      final c = ProviderContainer(
        overrides: [
          entitlementProvider.overrideWith(
            () => _FixedEntitlement(Entitlement.subscribed),
          ),
          adsPlatformProvider.overrideWithValue(true),
          trackingAuthorizationProvider.overrideWithValue(() async => true),
          adsInitAttemptProvider.overrideWithValue(() async {
            calls.add(1);
            return true;
          }),
        ],
      );
      addTearDown(c.dispose);

      await expectLater(
        c.read(adsInitializerProvider.future),
        completion(isFalse),
      );
      expect(calls, isEmpty);
    });
  });

  group('InterstitialAds', () {
    test('shows nothing until the SDK is up', () async {
      var transitions = 0;
      final ads = InterstitialAds(
        _CountingPolicy(() => transitions++),
        isReady: () => false,
      );

      await ads.onTransition();

      // The policy is never consulted, so a transition spent while the SDK was
      // still coming up does not count toward the next ad either.
      expect(transitions, 0);
    });
  });

  group('BannerRetry', () {
    test('retries a failed load with a widening gap, then gives up', () {
      var loads = 0;
      final scheduled = <Duration>[];
      final retry = BannerRetry(
        load: () async => loads++,
        delays: const [Duration(seconds: 5), Duration(seconds: 20)],
        schedule: (delay, run) {
          scheduled.add(delay);
          run();
        },
      );

      retry.start();
      expect(loads, 1);

      retry.onFailure();
      retry.onFailure();
      // Bounded: the third failure schedules nothing rather than retrying for
      // the rest of the session.
      retry.onFailure();

      expect(scheduled, const [Duration(seconds: 5), Duration(seconds: 20)]);
      expect(loads, 3);
    });

    test('a load that succeeds gives the next failure a full budget', () {
      var loads = 0;
      final scheduled = <Duration>[];
      final retry = BannerRetry(
        load: () async => loads++,
        delays: const [Duration(seconds: 5)],
        schedule: (delay, run) {
          scheduled.add(delay);
          run();
        },
      );

      retry.start();
      retry.onFailure();
      retry.onLoaded();
      retry.onFailure();

      expect(scheduled, const [Duration(seconds: 5), Duration(seconds: 5)]);
      expect(loads, 3);
    });
  });
}
