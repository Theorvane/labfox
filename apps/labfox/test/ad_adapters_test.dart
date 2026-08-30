import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the mediation adapter that gives the ad units something to serve.
///
/// LevelPlay's `mediation-sdk` is the auction, not a demand source. Shipping it
/// alone leaves the waterfall with no network it can instantiate — the device
/// log said `AdapterRepository: UnityAds adapter was not loaded` and every ad
/// unit stayed empty. The adapter, and the network SDK it adapts, have to be in
/// the app build on both platforms or the free tier shows nothing.
void main() {
  final gradle = File('android/app/build.gradle.kts');
  final podfile = File('ios/Podfile');

  test('Android ships the Unity Ads adapter and the SDK it adapts', () {
    final contents = gradle.readAsStringSync();

    expect(
      contents,
      contains('com.unity3d.ads-mediation:unityads-adapter'),
      reason: 'Without the adapter LevelPlay cannot instantiate the network.',
    );
    // The adapter's POM declares no dependencies, so the network SDK it wraps
    // has to be asked for by name.
    expect(
      contents,
      contains('com.unity3d.ads:unity-ads'),
      reason: 'The adapter wraps this SDK and does not pull it in itself.',
    );
  });

  test('Android grants the connection-type permission the SDK asks for', () {
    // "Unity Ads was not able to get current network type due to missing
    // permission" in the device log. It is a normal permission — no prompt.
    expect(
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync(),
      contains('android.permission.ACCESS_NETWORK_STATE'),
    );
  });

  test('iOS ships the same adapter', () {
    final contents = podfile.readAsStringSync();

    expect(contents, contains("pod 'IronSourceUnityAdsAdapter'"));
  });
}
