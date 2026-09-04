import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/core/ads/app_active.dart';

/// iOS shows the tracking prompt only while the app is active. Asked earlier,
/// `requestTrackingAuthorization` returns without ever putting anything on
/// screen — which reads as a user who refused, and leaves the app tracking
/// without having asked. A frame having been drawn does not mean active, so
/// the lifecycle state is what this waits on.
void main() {
  testWidgets('waits while the app is not yet active', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);

    var active = false;
    final waiting = whenAppActive().then((value) => active = value);
    await tester.pump();

    expect(active, isFalse, reason: 'inactive is not a moment to ask');

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await waiting;

    expect(active, isTrue);
  });

  testWidgets('returns at once when the app is already active', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    expect(await whenAppActive(), isTrue);
  });

  testWidgets('gives up rather than waiting forever', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);

    // An app launched into the background may never come forward this run.
    // Reporting that is what lets the caller decline to start the ad SDK,
    // rather than starting it with no permission behind it.
    final waiting = whenAppActive(timeout: const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 6));

    expect(await waiting, isFalse);
  });
}
