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

    testWidgets('shows a project context above the primary title', (
      tester,
    ) async {
      await _pump(
        tester,
        const WorkTile(
          icon: Icons.merge,
          contextLabel: 'gitlab-org/gitlab',
          title: 'Keep the primary work title easy to scan',
        ),
      );

      final context = find.text('gitlab-org/gitlab');
      final title = find.text('Keep the primary work title easy to scan');
      expect(context, findsOneWidget);
      expect(
        tester.getTopLeft(context).dy,
        lessThan(tester.getTopLeft(title).dy),
      );
    });

    testWidgets('truncates project context without overflowing a phone row', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pump(
        tester,
        const WorkTile(
          icon: Icons.adjust,
          contextLabel:
              'a-very-long-group-name/another-group/a-very-long-project-name',
          title: 'Fix the mobile layout',
          trailing: Icon(Icons.chevron_right),
        ),
      );

      final context = tester.widget<Text>(find.textContaining('a-very-long'));
      expect(context.maxLines, 1);
      expect(context.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
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
