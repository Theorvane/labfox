import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: LabFoxTheme.light,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('StatusPill', () {
    testWidgets('shows the label in the status foreground on its container', (
      tester,
    ) async {
      const colors = LabFoxStatusColors.light;
      await _pump(tester, StatusPill(label: 'Open', colors: colors.open));

      expect(find.text('Open'), findsOneWidget);

      final text = tester.widget<Text>(find.text('Open'));
      expect(text.style?.color, colors.open.foreground);

      final box = tester.widget<DecoratedBox>(
        find
            .ancestor(
              of: find.text('Open'),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect((box.decoration as BoxDecoration).color, colors.open.container);
    });

    testWidgets('renders a leading dot when asked', (tester) async {
      await _pump(
        tester,
        StatusPill(
          label: 'Merged',
          colors: LabFoxStatusColors.light.merged,
          dot: true,
        ),
      );
      // The dot is a small circular decorated box tinted with the foreground.
      final boxes = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((b) => b.decoration)
          .whereType<BoxDecoration>();
      expect(
        boxes.any(
          (d) =>
              d.shape == BoxShape.circle &&
              d.color == LabFoxStatusColors.light.merged.foreground,
        ),
        isTrue,
      );
    });

    testWidgets('renders a leading icon when given', (tester) async {
      await _pump(
        tester,
        StatusPill(
          label: 'Failed',
          colors: LabFoxStatusColors.light.closed,
          icon: Icons.close,
        ),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
