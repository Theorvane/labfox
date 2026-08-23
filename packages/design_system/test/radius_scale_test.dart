import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the corner-radius scale to GitLab's.
///
/// Verified against the published `@gitlab/ui` package: its scale is 2, 4
/// (the default), 8, 12, and full. LabFox was 6, 9, 12, 14 — every step
/// rounder, with its smallest corner larger than GitLab's default and its
/// middle equal to GitLab's largest. Softer corners are what made the app read
/// as belonging somewhere other than GitLab, even once the palette matched.
///
/// The values are GitLab's because a shape scale carries no brand — unlike
/// colour, where copying GitLab's own values would make an unofficial client
/// look like the official app. See issue #191.
void main() {
  test('the scale matches GitLab, and stays ordered', () {
    expect(LabFoxRadius.xs, 2);
    expect(LabFoxRadius.sm, 4);
    expect(LabFoxRadius.md, 8);
    expect(LabFoxRadius.lg, 12);

    final scale = [
      LabFoxRadius.xs,
      LabFoxRadius.sm,
      LabFoxRadius.md,
      LabFoxRadius.lg,
    ];
    for (var i = 1; i < scale.length; i++) {
      expect(
        scale[i],
        greaterThan(scale[i - 1]),
        reason: 'the scale must ascend, or the names stop meaning anything',
      );
    }
  });

  test('pill stays fully rounded', () {
    // GitLab's equivalent is `full` at 9999px. Anything large enough reads the
    // same; what matters is that it is not a step on the scale above.
    expect(LabFoxRadius.pill, greaterThan(LabFoxRadius.lg * 10));
  });
}
