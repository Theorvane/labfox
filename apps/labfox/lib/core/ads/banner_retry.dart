import 'dart:async';

/// Waits [delay], then runs the retry. Injected in tests so a retry does not
/// have to take real seconds.
typedef BannerSchedule = void Function(Duration delay, void Function() run);

/// Reloads a banner whose load failed, a bounded number of times.
///
/// A [LevelPlayBannerAdView] loads once, when its platform view is created.
/// Anything that fails that one attempt — a no-fill, a network blip, an SDK
/// that was not up yet — leaves the slot empty for the rest of the session,
/// because nothing asks again. Retrying with a widening gap costs nothing when
/// the first load succeeds and recovers the slot when it does not.
///
/// Bounded on purpose: a banner that cannot fill is usually a configuration
/// answer, not a timing one, and retrying forever spends the user's battery
/// and data arguing with it.
class BannerRetry {
  BannerRetry({
    required Future<void> Function() load,
    List<Duration> delays = defaultDelays,
    BannerSchedule? schedule,
  }) : _load = load,
       _delays = delays {
    _schedule = schedule ?? _afterDelay;
  }

  static const defaultDelays = [
    Duration(seconds: 5),
    Duration(seconds: 20),
    Duration(seconds: 60),
  ];

  final Future<void> Function() _load;
  final List<Duration> _delays;
  late final BannerSchedule _schedule;

  int _attempt = 0;
  Timer? _timer;

  void _afterDelay(Duration delay, void Function() run) {
    _timer = Timer(delay, run);
  }

  /// The first load, once the SDK is up and the view exists.
  void start() {
    _attempt = 0;
    _timer?.cancel();
    unawaited(_load());
  }

  /// A load that failed. Schedules the next attempt, or gives up.
  void onFailure() {
    if (_attempt >= _delays.length) {
      return;
    }
    final delay = _delays[_attempt++];
    _timer?.cancel();
    _schedule(delay, () => unawaited(_load()));
  }

  /// A load that worked. The next failure — banners refresh on their own —
  /// starts from a full budget rather than the tail of the last one.
  void onLoaded() {
    _attempt = 0;
    _timer?.cancel();
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
