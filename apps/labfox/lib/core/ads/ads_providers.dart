import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';

import '../entitlement/entitlement_providers.dart';
import 'ads_config.dart';
import 'interstitial_policy.dart';

/// Whether this user sees ads: the free mobile tier only.
///
/// Desktop builds report `subscribed` (fully featured, free), so they are
/// excluded here automatically, and subscribing removes ads on the next frame.
final adsEnabledProvider = Provider<bool>((ref) {
  return !ref.watch(entitlementProvider).isSubscribed;
});

/// Builds the live banner view. A seam so widget tests can render a stand-in
/// instead of the platform view the plugin needs a real device for.
final bannerViewBuilderProvider = Provider<Widget Function(BuildContext)>((
  ref,
) {
  return (context) {
    final size = LevelPlayAdSize.BANNER;
    return SizedBox(
      width: size.width.toDouble(),
      height: size.height.toDouble(),
      child: LevelPlayBannerAdView(
        key: ref.watch(_bannerKeyProvider),
        adUnitId: AdsConfig.bannerAdUnitId,
        adSize: size,
        listener: const _BannerListener(),
        placementName: 'DefaultBanner',
        onPlatformViewCreated: () {
          ref.read(_bannerKeyProvider).currentState?.loadAd();
        },
      ),
    );
  };
});

final _bannerKeyProvider = Provider<GlobalKey<LevelPlayBannerAdViewState>>(
  (ref) => GlobalKey<LevelPlayBannerAdViewState>(),
);

/// Initializes the LevelPlay SDK once, only on ad-gated builds.
///
/// Failures are swallowed: ads must never block or break the app; a failed
/// init simply means the banner stays empty and interstitials never load.
final adsInitializerProvider = FutureProvider<void>((ref) async {
  if (!Platform.isAndroid && !Platform.isIOS) {
    return;
  }
  if (!ref.read(adsEnabledProvider)) {
    return;
  }
  try {
    final request = LevelPlayInitRequest.builder(AdsConfig.appKey).build();
    await LevelPlay.init(
      initRequest: request,
      initListener: const _InitListener(),
    );
  } catch (_) {
    // Ads are optional; never surface an init failure.
  }
});

/// Loads and paces interstitials across screen transitions.
class InterstitialAds {
  InterstitialAds(this._policy);

  final InterstitialPolicy _policy;
  LevelPlayInterstitialAd? _ad;

  LevelPlayInterstitialAd _instance() {
    return _ad ??= LevelPlayInterstitialAd(
      adUnitId: AdsConfig.interstitialAdUnitId,
    )..loadAd();
  }

  /// Called on every route change; shows when the policy allows and an ad is
  /// ready, then starts loading the next one.
  Future<void> onTransition() async {
    try {
      final ad = _instance();
      if (!_policy.onTransition()) {
        return;
      }
      if (await ad.isAdReady()) {
        unawaited(ad.showAd(placementName: 'Default'));
      }
      unawaited(ad.loadAd());
    } catch (_) {
      // Ads are optional; a platform error never surfaces.
    }
  }
}

final interstitialAdsProvider = Provider<InterstitialAds>((ref) {
  return InterstitialAds(InterstitialPolicy());
});

class _InitListener with LevelPlayInitListener {
  const _InitListener();

  @override
  void onInitFailed(LevelPlayInitError error) {}

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) {}
}

class _BannerListener with LevelPlayBannerAdViewListener {
  const _BannerListener();

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {}

  @override
  void onAdCollapsed(LevelPlayAdInfo adInfo) {}

  @override
  void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) {}

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {}

  @override
  void onAdExpanded(LevelPlayAdInfo adInfo) {}

  @override
  void onAdLeftApplication(LevelPlayAdInfo adInfo) {}

  @override
  void onAdLoadFailed(LevelPlayAdError error) {}

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {}
}
