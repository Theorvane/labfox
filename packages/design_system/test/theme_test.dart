import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LabFoxTheme', () {
    test('light and dark are actually different brightnesses', () {
      expect(LabFoxTheme.light.brightness, Brightness.light);
      expect(LabFoxTheme.dark.brightness, Brightness.dark);
    });

    test('both themes use Material 3', () {
      expect(LabFoxTheme.light.useMaterial3, isTrue);
      expect(LabFoxTheme.dark.useMaterial3, isTrue);
    });

    test('buttons meet the minimum touch target in both themes', () {
      for (final theme in [LabFoxTheme.light, LabFoxTheme.dark]) {
        final size = theme.filledButtonTheme.style?.minimumSize?.resolve(
          <WidgetState>{},
        );
        expect(
          size?.height,
          greaterThanOrEqualTo(LabFoxSpacing.minTouchTarget),
        );
      }
    });
  });
}
