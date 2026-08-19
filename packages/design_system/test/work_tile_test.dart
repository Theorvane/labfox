import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: LabFoxTheme.light,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('WorkTile', () {
    testWidgets('shows the icon, title, metadata and trailing', (tester) async {
      await _pump(
        tester,
        WorkTile(
          icon: Icons.merge,
          iconColor: LabFoxStatusColors.light.open.foreground,
          title: 'Add unified diff viewer',
          metadata: const [Text('!142'), Text('labfox/app')],
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      );

      expect(find.text('Add unified diff viewer'), findsOneWidget);
      expect(find.text('!142'), findsOneWidget);
      expect(find.text('labfox/app'), findsOneWidget);
      expect(find.byIcon(Icons.merge), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('invokes onTap', (tester) async {
      var tapped = 0;
      await _pump(
        tester,
        WorkTile(icon: Icons.adjust, title: 'Bug', onTap: () => tapped++),
      );

      await tester.tap(find.byType(WorkTile));
      expect(tapped, 1);
    });

    testWidgets('is not tappable without onTap', (tester) async {
      await _pump(tester, const WorkTile(icon: Icons.adjust, title: 'Bug'));
      final inkwell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkwell.onTap, isNull);
    });

    testWidgets('truncates a long title to two lines', (tester) async {
      await _pump(
        tester,
        const WorkTile(
          icon: Icons.adjust,
          title:
              'A very long merge request title that should be clamped to two '
              'lines and then truncated with an ellipsis rather than overflow',
        ),
      );
      final text = tester.widget<Text>(find.textContaining('A very long'));
      expect(text.maxLines, 2);
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });
}
