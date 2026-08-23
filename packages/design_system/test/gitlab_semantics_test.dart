import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the status colours to GitLab's semantic system.
///
/// Verified against the published `@gitlab/ui` package rather than assumed.
/// Two facts from it drive everything here:
///
/// GitLab defines **no** merge-request or pipeline specific colours. Not one
/// token matches `merge`, `pipeline` or `ci`; every state reuses one semantic
/// set — neutral, info, success, warning, danger, tier — and the badge
/// component ships exactly those variants.
///
/// Purple is GitLab's **brand** colour, not a status. So colouring a merged
/// merge request purple, which this app inherited from GitHub, was wrong twice:
/// it is GitHub's convention, and in GitLab's system purple means GitLab.
void main() {
  /// The hue band each GitLab meaning occupies, in degrees.
  ///
  /// Bands rather than exact values on purpose: the meanings come from GitLab,
  /// the hues stay LabFox's. Copying GitLab's own values would make an
  /// unofficial client look like the official app, which the store listing
  /// explicitly denies and AGENTS.md §1 forbids.
  const bands = <String, (double, double)>{
    'success': (90, 175), // green
    'info': (175, 260), // teal through blue
    'danger': (330, 20), // red, wrapping through zero
    'warning': (20, 60), // amber
  };

  bool inBand(double hue, (double, double) band) {
    final (from, to) = band;
    return from <= to ? hue >= from && hue <= to : hue >= from || hue <= to;
  }

  void expectMeaning(String label, StatusColor colour, String meaning) {
    final hue = HSLColor.fromColor(colour.foreground).hue;
    expect(
      inBand(hue, bands[meaning]!),
      isTrue,
      reason:
          '$label should read as GitLab\'s "$meaning" but is hue '
          '${hue.round()}. See issue #191.',
    );
  }

  for (final entry in {
    'light': LabFoxStatusColors.light,
    'dark': LabFoxStatusColors.dark,
  }.entries) {
    final palette = entry.value;
    final theme = entry.key;

    test('$theme follows GitLab\'s meanings', () {
      // An open issue or merge request is green in GitLab.
      expectMeaning('open', palette.open, 'success');
      // GitLab has no merged colour, so a merged MR takes info.
      expectMeaning('merged', palette.merged, 'info');
      expectMeaning('closed', palette.closed, 'danger');
      // A running pipeline is info in GitLab, same as merged.
      expectMeaning('running', palette.running, 'info');
      expectMeaning('warning', palette.warning, 'warning');
    });

    test('$theme keeps pending neutral', () {
      // neutral in GitLab's set: grey, carrying no hue signal of its own.
      final pending = HSLColor.fromColor(palette.pending.foreground);
      expect(
        pending.saturation,
        lessThan(0.2),
        reason: 'pending should read as neutral, not as a hue',
      );
    });

    test('$theme does not use purple, which is GitLab\'s brand', () {
      for (final colour in [
        palette.open,
        palette.merged,
        palette.closed,
        palette.running,
        palette.pending,
        palette.warning,
      ]) {
        final hue = HSLColor.fromColor(colour.foreground).hue;
        final saturated =
            HSLColor.fromColor(colour.foreground).saturation > 0.2;
        expect(
          saturated && hue > 260 && hue < 330,
          isFalse,
          reason:
              'hue ${hue.round()} is purple. In GitLab that means GitLab '
              'itself, not a status.',
        );
      }
    });
  }

  test('merged and running share a colour, as they do in GitLab', () {
    // Not an oversight. GitLab gives both the same meaning, and they are told
    // apart by icon and label — which is what status_colors.dart already
    // promises: colour is never the only signal. The promise is worth a test
    // because these two appear in one list on the inbox and in search.
    for (final palette in [LabFoxStatusColors.light, LabFoxStatusColors.dark]) {
      final merged = HSLColor.fromColor(palette.merged.foreground).hue;
      final running = HSLColor.fromColor(palette.running.foreground).hue;
      expect(
        inBand(merged, bands['info']!) && inBand(running, bands['info']!),
        isTrue,
        reason: 'both should sit in the info band',
      );
    }
  });
}
