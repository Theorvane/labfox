import 'dart:io';

/// LevelPlay app keys and ad-unit ids.
///
/// These are public identifiers, like any ad-unit id shipped inside an app
/// binary — they grant no access to the ad account. Each one can be overridden
/// at build time with `--dart-define` so a fork or a test build can point at
/// its own LevelPlay project.
abstract final class AdsConfig {
  static const _androidAppKey = String.fromEnvironment(
    'LEVELPLAY_ANDROID_APP_KEY',
    defaultValue: '27d59fefd',
  );
  static const _iosAppKey = String.fromEnvironment(
    'LEVELPLAY_IOS_APP_KEY',
    defaultValue: '27d59c575',
  );

  static const _androidBanner = String.fromEnvironment(
    'LEVELPLAY_ANDROID_BANNER',
    defaultValue: 'e2to4i6libgyj3wg',
  );
  static const _iosBanner = String.fromEnvironment(
    'LEVELPLAY_IOS_BANNER',
    defaultValue: 'c5xs0c9wz57umuof',
  );

  static const _androidInterstitial = String.fromEnvironment(
    'LEVELPLAY_ANDROID_INTERSTITIAL',
    defaultValue: 'vsg6jh3jln8gas7z',
  );
  static const _iosInterstitial = String.fromEnvironment(
    'LEVELPLAY_IOS_INTERSTITIAL',
    defaultValue: '3zg1ox66iixapl8p',
  );

  /// Reserved for the native-ads follow-up; listed so the ids live in one
  /// place from the start.
  static const androidNative = String.fromEnvironment(
    'LEVELPLAY_ANDROID_NATIVE',
    defaultValue: 'ojs884z7z0joos0t',
  );
  static const iosNative = String.fromEnvironment(
    'LEVELPLAY_IOS_NATIVE',
    defaultValue: 'mz0f6kra0wotizz9',
  );

  static String get appKey => Platform.isIOS ? _iosAppKey : _androidAppKey;
  static String get bannerAdUnitId =>
      Platform.isIOS ? _iosBanner : _androidBanner;
  static String get interstitialAdUnitId =>
      Platform.isIOS ? _iosInterstitial : _androidInterstitial;
}
