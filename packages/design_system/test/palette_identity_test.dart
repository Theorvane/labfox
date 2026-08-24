import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the palette against drifting back into GitHub's.
///
/// The status colours were GitHub's Primer values, including its merged-purple,
/// which is GitHub's convention and not GitLab's — the app looked borrowed
/// while being wrong about the platform it is a client for. Colour choices are
/// the kind of thing that gets "fixed" back by whoever next reaches for a
/// familiar hex, so the ones that mattered are pinned here with the reason.
void main() {
  /// GitHub Primer values that were in this file's history. Any of these
  /// reappearing means the palette has drifted back.
  const primer = <String, int>{
    'Primer open green': 0xFF1A7F37,
    'Primer merged purple': 0xFF8250DF,
    'Primer closed red': 0xFFCF222E,
    'Primer dark open green': 0xFF3FB950,
    'Primer dark merged purple': 0xFFA371F7,
    'Primer dark closed red': 0xFFF85149,
  };

  List<Color> statusColours(LabFoxStatusColors s) => [
    s.open.foreground,
    s.merged.foreground,
    s.closed.foreground,
    s.running.foreground,
    s.pending.foreground,
    s.warning.foreground,
  ];

  for (final entry in {
    'light': LabFoxStatusColors.light,
    'dark': LabFoxStatusColors.dark,
  }.entries) {
    test('the ${entry.key} status palette is not GitHub Primer', () {
      final used = statusColours(entry.value).map((c) => c.toARGB32()).toSet();
      for (final primerEntry in primer.entries) {
        expect(
          used,
          isNot(contains(primerEntry.value)),
          reason:
              '${primerEntry.key} (#${primerEntry.value.toRadixString(16)}) is '
              'back in the ${entry.key} palette. See issue #187.',
        );
      }
    });
  }

  test('merged is not purple, because that is GitHub\'s convention', () {
    // Hue 250-300 is the purple/violet band. GitLab does not colour merge
    // requests purple; borrowing it made the app look like a GitHub client.
    for (final entry in {
      'light': LabFoxStatusColors.light,
      'dark': LabFoxStatusColors.dark,
    }.entries) {
      final hue = HSLColor.fromColor(entry.value.merged.foreground).hue;
      expect(
        hue > 250 && hue < 300,
        isFalse,
        reason:
            'merged is hue ${hue.round()} in ${entry.key}, which is purple. '
            'See issue #187.',
      );
    }
  });

  test('every status stays distinguishable in greyscale', () {
    // status_colors.dart promises colour is never the only signal, but two
    // statuses collapsing to the same grey would still make lists harder to
    // scan for anyone who cannot separate the hues.
    for (final entry in {
      'light': LabFoxStatusColors.light,
      'dark': LabFoxStatusColors.dark,
    }.entries) {
      final lumas = statusColours(
        entry.value,
      ).map((c) => c.computeLuminance()).toList();
      for (var i = 0; i < lumas.length; i++) {
        for (var j = i + 1; j < lumas.length; j++) {
          expect(
            (lumas[i] - lumas[j]).abs(),
            greaterThan(0.01),
            reason:
                'two ${entry.key} statuses have effectively the same luminance, '
                'so they are indistinguishable without colour',
          );
        }
      }
    }
  });

  test('the theme surfaces are not the neutral grey every client uses', () {
    // The status palette moved first and this was missed: the ColorScheme still
    // carried Primer's red, and both surfaces were cool neutral greys — the
    // look the palette change was meant to leave behind. Light is warm paper,
    // dark is tinted with the brand navy.
    for (final theme in [LabFoxTheme.light, LabFoxTheme.dark]) {
      final scheme = theme.colorScheme;
      expect(
        scheme.error.toARGB32(),
        isNot(anyOf(0xFFCF222E, 0xFFF85149)),
        reason: "the scheme's error is back on GitHub Primer's red",
      );
      expect(
        scheme.surface,
        isNot(Colors.white),
        reason:
            'a pure white surface is what made this read as every other '
            'code-hosting client',
      );
    }

    // Both surfaces lean toward the brand rather than sitting on neutral grey:
    // the light one warm, the dark one navy.
    final light = HSLColor.fromColor(LabFoxTheme.light.colorScheme.surface);
    final dark = HSLColor.fromColor(LabFoxTheme.dark.colorScheme.surface);
    expect(
      light.saturation,
      greaterThan(0.05),
      reason: 'light surface is tinted',
    );
    expect(
      dark.saturation,
      greaterThan(0.05),
      reason: 'dark surface is tinted',
    );
  });

  test('body and secondary text stay legible on both surfaces', () {
    // Warming a surface is exactly the change that quietly costs contrast.
    double ratio(Color a, Color b) {
      final la = a.computeLuminance();
      final lb = b.computeLuminance();
      return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
    }

    for (final theme in [LabFoxTheme.light, LabFoxTheme.dark]) {
      final s = theme.colorScheme;
      expect(
        ratio(s.onSurface, s.surface),
        greaterThanOrEqualTo(7.0),
        reason: 'body text should clear AAA',
      );
      expect(
        ratio(s.onSurfaceVariant, s.surface),
        greaterThanOrEqualTo(4.5),
        reason: 'secondary text should clear AA',
      );
    }
  });

  test('the brand colours are what the app actually builds on', () {
    // The palette existed but the app was white-and-neutral, which is what
    // made it read as GitHub Mobile. These are the two that must stay.
    expect(LabFoxColors.navy.toARGB32(), 0xFF071230);
    expect(LabFoxColors.orange.toARGB32(), 0xFFF54714);
  });
}
