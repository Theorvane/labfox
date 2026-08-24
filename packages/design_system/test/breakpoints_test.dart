import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LabFoxBreakpoints.of', () {
    test('below 600 is mobile', () {
      expect(LabFoxBreakpoints.of(599), LayoutSize.mobile);
    });

    test('600 is the first tablet width', () {
      expect(LabFoxBreakpoints.of(600), LayoutSize.tablet);
    });

    test('999 is still tablet', () {
      expect(LabFoxBreakpoints.of(999), LayoutSize.tablet);
    });

    test('1000 is the first desktop width', () {
      expect(LabFoxBreakpoints.of(1000), LayoutSize.desktop);
    });

    test('a zero width does not throw', () {
      // Windows report zero size for a frame or two during startup and when a
      // desktop window is minimised.
      expect(LabFoxBreakpoints.of(0), LayoutSize.mobile);
    });
  });

  group('LayoutSize', () {
    test('isWide covers everything with room for two panes', () {
      expect(LayoutSize.mobile.isWide, isFalse);
      expect(LayoutSize.tablet.isWide, isTrue);
      expect(LayoutSize.desktop.isWide, isTrue);
    });
  });
}
