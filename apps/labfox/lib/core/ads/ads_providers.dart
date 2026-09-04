import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';

import '../entitlement/entitlement_providers.dart';
import 'ads_config.dart';
import 'banner_retry.dart';
import 'interstitial_policy.dart';

/// What the banner view tells the shell.
///
/// Only the arrival of an ad matters: the slot starts collapsed, so there is
/// nothing to report on a failure — and once an ad is on screen the shell
/// keeps the space rather than pulling it away under the reader.
class BannerViewCallbacks {
  const BannerViewCallbacks({required this.onLoaded});

  final VoidCallback onLoaded;
}

/// Whether this user sees ads: the free mobile tier only.
///
/// Desktop builds report `subscribed` (fully featured, free), so they are
/// excluded here automatically, and subscribing removes ads on the next frame.
final adsEnabledProvider = Provider<bool>((ref) {
  return !ref.watch(entitlementProvider).isSubscribed;
});

/// Builds the live banner view. A seam so widget tests can render a stand-in
/// instead of the platform view the plugin needs a real device for.
final bannerViewBuilderProvider =
    Provider<Widget Function(BuildContext, BannerViewCallbacks)>((ref) {
      final key = ref.watch(_bannerKeyProvider);
      final retry = BannerRetry(load: () async => key.currentState?.loadAd());
      ref.onDispose(retry.cancel);
      return (context, callbacks) {
        final size = LevelPlayAdSize.BANNER;
        return SizedBox(
          width: size.width.toDouble(),
          height: size.height.toDouble(),
          child: LevelPlayBannerAdView(
            key: key,
            adUnitId: AdsConfig.bannerAdUnitId,
            adSize: size,
            listener: _BannerListener(retry, callbacks),
            placementName: 'DefaultBanner',
            // The view only loads when asked, and this is the first moment there
            // is anything to ask.
            onPlatformViewCreated: retry.start,
          ),
        );
      };
    });

final _bannerKeyProvider = Provider<GlobalKey<LevelPlayBannerAdViewState>>(
  (ref) => GlobalKey<LevelPlayBannerAdViewState>(),
);

/// Whether this platform has an ad SDK at all. A seam so the provider's own
/// logic is testable off-device.
final adsPlatformProvider = Provider<bool>((ref) {
  return Platform.isAndroid || Platform.isIOS;
});

/// One attempt at bringing the SDK up, reporting whether it came up.
///
/// A seam so the retry loop can be tested without the platform channel.
final adsInitAttemptProvider = Provider<Future<bool> Function()>((ref) {
  return _initLevelPlayOnce;
});

/// How long to wait between init attempts. One entry per retry.
final adsInitBackoffProvider = Provider<List<Duration>>((ref) {
  return const [Duration(seconds: 5), Duration(seconds: 30)];
});

/// Brings the LevelPlay SDK up on ad-gated builds and reports whether it made
/// it, retrying a failed attempt a bounded number of times.
///
/// The result gates every ad. `LevelPlay.init` returning only means the call
/// reached the SDK; the answer arrives on the listener, and an ad asked to load
/// before it does is rejected outright — error 625, "Load must be called after
/// init success callback" — which spends the banner view's one load attempt and
/// leaves the slot empty for the session.
///
/// Retried because the usual first-launch failure is transient: a cold start
/// that has not got DNS yet fails with a resolve error, and nothing would ever
/// ask again. Bounded because a wrong app key fails identically forever.
final adsInitializerProvider = FutureProvider<bool>((ref) async {
  if (!ref.watch(adsPlatformProvider)) {
    return false;
  }
  if (!ref.watch(adsEnabledProvider)) {
    return false;
  }
  final attempt = ref.watch(adsInitAttemptProvider);
  final backoff = ref.watch(adsInitBackoffProvider);
  for (var i = 0; i <= backoff.length; i++) {
    if (await attempt()) {
      return true;
    }
    if (i < backoff.length) {
      await Future<void>.delayed(backoff[i]);
    }
  }
  return false;
});

/// Long enough for a cold start on a slow network, short enough that a dead
/// SDK does not keep the slot pending for the whole session.
const _initTimeout = Duration(seconds: 30);

Future<bool> _initLevelPlayOnce() async {
  final ready = Completer<bool>();
  try {
    final request = LevelPlayInitRequest.builder(AdsConfig.appKey).build();
    await LevelPlay.init(
      initRequest: request,
      initListener: _InitListener(ready),
    );
  } catch (_) {
    // Ads are optional; never surface an init failure.
    return false;
  }
  return ready.future.timeout(_initTimeout, onTimeout: () => false);
}

/// Loads and paces interstitials across screen transitions.
class InterstitialAds {
  InterstitialAds(this._policy, {required bool Function() isReady})
    : _isReady = isReady;

  final InterstitialPolicy _policy;

  /// Whether the SDK is up. Constructing the ad object loads it, and a load
  /// before init success is rejected and never retried, so nothing here
  /// touches the SDK until this says yes.
  final bool Function() _isReady;

  LevelPlayInterstitialAd? _ad;

  LevelPlayInterstitialAd _instance() {
    return _ad ??= LevelPlayInterstitialAd(
      adUnitId: AdsConfig.interstitialAdUnitId,
    )..loadAd();
  }

  /// Called on every route change; shows when the policy allows and an ad is
  /// ready, then starts loading the next one.
  Future<void> onTransition() async {
    if (!_isReady()) {
      return;
    }
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
  return InterstitialAds(
    InterstitialPolicy(),
    isReady: () => ref.read(adsInitializerProvider).valueOrNull ?? false,
  );
});

class _InitListener with LevelPlayInitListener {
  _InitListener(this._ready);

  final Completer<bool> _ready;

  @override
  void onInitFailed(LevelPlayInitError error) => _complete(false);

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) => _complete(true);

  // The SDK is free to call back more than once; the first answer is the one.
  void _complete(bool success) {
    if (!_ready.isCompleted) {
      _ready.complete(success);
    }
  }
}

class _BannerListener with LevelPlayBannerAdViewListener {
  const _BannerListener(this._retry, this._callbacks);

  final BannerRetry _retry;
  final BannerViewCallbacks _callbacks;

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {}

  @override
  void onAdCollapsed(LevelPlayAdInfo adInfo) {}

  @override
  void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) =>
      _retry.onFailure();

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) => _callbacks.onLoaded();

  @override
  void onAdExpanded(LevelPlayAdInfo adInfo) {}

  @override
  void onAdLeftApplication(LevelPlayAdInfo adInfo) {}

  @override
  void onAdLoadFailed(LevelPlayAdError error) => _retry.onFailure();

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    _callbacks.onLoaded();
    _retry.onLoaded();
  }
}
