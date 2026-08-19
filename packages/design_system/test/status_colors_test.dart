import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LabFoxStatusColors', () {
    test('light and dark are distinct palettes', () {
      expect(
        LabFoxStatusColors.light.open.foreground,
        isNot(LabFoxStatusColors.dark.open.foreground),
      );
      expect(
        LabFoxStatusColors.light.merged.container,
        isNot(LabFoxStatusColors.dark.merged.container),
      );
    });

    test('every status has a distinct foreground within a palette', () {
      const p = LabFoxStatusColors.light;
      final fgs = {
        p.open.foreground,
        p.merged.foreground,
        p.closed.foreground,
        p.running.foreground,
        p.warning.foreground,
      };
      // Merged must not read as closed, running must not read as open, etc.
      expect(fgs.length, 5);
    });

    test('lerp interpolates toward the other palette', () {
      final mid = LabFoxStatusColors.light.lerp(LabFoxStatusColors.dark, 1);
      expect(mid.open.foreground, LabFoxStatusColors.dark.open.foreground);
    });

    test('copyWith replaces only the given status', () {
      const replacement = StatusColor(
        foreground: Color(0xFF000000),
        container: Color(0xFFFFFFFF),
      );
      final updated = LabFoxStatusColors.light.copyWith(open: replacement);
      expect(updated.open, replacement);
      expect(updated.closed, LabFoxStatusColors.light.closed);
    });

    testWidgets('resolves from the theme by brightness', (tester) async {
      late LabFoxStatusColors resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: LabFoxTheme.light,
          home: Builder(
            builder: (context) {
              resolved = LabFoxStatusColors.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(
        resolved.open.foreground,
        LabFoxStatusColors.light.open.foreground,
      );
    });

    testWidgets('both themes carry the extension', (tester) async {
      expect(LabFoxTheme.light.extension<LabFoxStatusColors>(), isNotNull);
      expect(LabFoxTheme.dark.extension<LabFoxStatusColors>(), isNotNull);
    });
  });
}
