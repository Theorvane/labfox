import 'dart:async';

import 'package:flutter/widgets.dart';

/// Waits until the app is the active, foreground app.
///
/// iOS shows the App Tracking Transparency prompt only while the application
/// is active. Asked earlier, `requestTrackingAuthorization` returns without
/// putting anything on screen — indistinguishable from a user who refused, and
/// it would leave the app tracking without having asked, which is the rejection
/// this exists to avoid. A frame having been drawn does not mean active, so
/// this waits on the lifecycle state rather than on the frame.
///
/// Returns false if the app does not become active within [timeout], which is
/// what an app launched into the background looks like. The caller declines to
/// start anything that would track, rather than starting it with no permission
/// behind it.
Future<bool> whenAppActive({
  Duration timeout = const Duration(seconds: 30),
}) async {
  final binding = WidgetsBinding.instance;
  if (binding.lifecycleState == AppLifecycleState.resumed) {
    return true;
  }

  final active = Completer<bool>();
  final listener = AppLifecycleListener(
    onStateChange: (state) {
      if (state == AppLifecycleState.resumed && !active.isCompleted) {
        active.complete(true);
      }
    },
  );
  try {
    return await active.future.timeout(timeout, onTimeout: () => false);
  } finally {
    listener.dispose();
  }
}
