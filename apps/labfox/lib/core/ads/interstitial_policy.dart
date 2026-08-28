/// Decides when a screen transition may show an interstitial.
///
/// Pure and clock-injected so the pacing is testable. An ad becomes *due*
/// every [every]th transition — never before the first cycle completes, so the
/// app never greets the user with an ad — and a due ad shows only once the
/// [cooldown] since the previous one has passed. A show deferred by the
/// cooldown stays due and is taken on the first transition after the cooldown
/// clears, rather than waiting a whole extra cycle.
class InterstitialPolicy {
  InterstitialPolicy({
    this.every = 7,
    this.cooldown = const Duration(minutes: 2),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final int every;
  final Duration cooldown;
  final DateTime Function() _clock;

  int _transitions = 0;
  bool _due = false;
  DateTime? _lastShown;

  /// Records one transition; true when an interstitial may show now.
  bool onTransition() {
    _transitions++;
    if (_transitions % every == 0) {
      _due = true;
    }
    if (!_due) {
      return false;
    }
    final last = _lastShown;
    final now = _clock();
    if (last != null && now.difference(last) < cooldown) {
      return false;
    }
    _due = false;
    _lastShown = now;
    return true;
  }
}
