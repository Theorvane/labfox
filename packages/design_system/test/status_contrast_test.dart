import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every `StatusColor` pair, in both themes, against WCAG AA.
///
/// The contract in `status_colors.dart` is that `foreground` is the icon *and
/// text* colour and `container` is the pill behind it. Text means the pair has
/// to clear 4.5:1, and four of them did not: light merged 3.80, pending 3.02,
/// warning 2.48, and dark closed 4.27.
///
/// They shipped because the contrast check written alongside them measured the
/// wrong pair — body text against the page surface, never chip text against its
/// own chip. This walks every pair instead of sampling, so a future palette
/// cannot pass by having the tested ones happen to be fine.
void main() {
  double luminance(Color c) {
    double channel(double v) {
      final s = v / 255.0;
      return s <= 0.03928
          ? s / 12.92
          : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * channel(c.r * 255) +
        0.7152 * channel(c.g * 255) +
        0.0722 * channel(c.b * 255);
  }

  double contrast(Color a, Color b) {
    final la = luminance(a);
    final lb = luminance(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  /// Named so a failure says which token, not just which index.
  Map<String, StatusColor> pairs(LabFoxStatusColors s) => {
    'open': s.open,
    'merged': s.merged,
    'closed': s.closed,
    'running': s.running,
    'pending': s.pending,
    'warning': s.warning,
  };

  for (final theme in {
    'light': LabFoxStatusColors.light,
    'dark': LabFoxStatusColors.dark,
  }.entries) {
    test('every ${theme.key} status pair clears AA for text', () {
      pairs(theme.value).forEach((name, colour) {
        final ratio = contrast(colour.foreground, colour.container);
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason:
              '$name is ${ratio.toStringAsFixed(2)}:1 in ${theme.key}. '
              'foreground is chip text, so it needs 4.5:1 against container.',
        );
      });
    });

    test('every ${theme.key} foreground is legible on the page surface', () {
      // Status icons are also drawn bare on the surface, not only inside a
      // chip, so that pairing needs to hold too. 3:1 is the AA floor for
      // non-text graphics.
      final surface =
          (theme.key == 'light' ? LabFoxTheme.light : LabFoxTheme.dark)
              .colorScheme
              .surface;
      pairs(theme.value).forEach((name, colour) {
        final ratio = contrast(colour.foreground, surface);
        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason:
              '$name icon is ${ratio.toStringAsFixed(2)}:1 on the '
              '${theme.key} surface',
        );
      });
    });
  }
}
