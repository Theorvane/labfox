import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/analytics/analytics.dart';

/// Owns the events that describe the app's own lifetime rather than anything
/// the user does inside it.
///
/// [appOpened] deliberately lives here instead of in `routerProvider`: that
/// provider watches the auth controller and is rebuilt on every sign-in,
/// account switch, and sign-out, so an `app_open` emitted there would count
/// session changes rather than launches.
class AppLifecycle {
  AppLifecycle(this._analytics);

  final Analytics _analytics;
  bool _opened = false;

  /// Records the launch. Only the first call emits, so a widget rebuild or a
  /// re-entrant bootstrap can never inflate the count.
  void appOpened() {
    if (_opened) {
      return;
    }
    _opened = true;
    unawaited(_analytics.track('app_open'));
  }
}

/// Depends on nothing that changes at runtime, so it is created once and its
/// "already opened" memory lasts as long as the app does.
final appLifecycleProvider = Provider<AppLifecycle>((ref) {
  return AppLifecycle(ref.read(analyticsProvider));
});
