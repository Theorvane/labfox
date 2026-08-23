import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness({List<WorkDestination>? destinations}) {
  return MaterialApp(
    theme: LabFoxTheme.light,
    home: Scaffold(
      body: WorkGrid(
        title: 'My work',
        destinations:
            destinations ??
            [
              WorkDestination(
                icon: LabFoxIcons.issueOpen,
                label: 'Issues',
                onTap: () {},
                count: 12,
              ),
              WorkDestination(
                icon: LabFoxIcons.mergeRequest,
                label: 'Merge requests',
                onTap: () {},
                count: 4,
              ),
              WorkDestination(
                icon: LabFoxIcons.project,
                label: 'Projects',
                onTap: () {},
              ),
              WorkDestination(
                icon: LabFoxIcons.inbox,
                label: 'To-do list',
                onTap: () {},
                count: 3,
              ),
            ],
      ),
    ),
  );
}

void main() {
  testWidgets('lays the destinations out two to a row', (tester) async {
    await tester.pumpWidget(_harness());

    // Two columns, not a list of rows: the row-of-tiles shape is the one every
    // code-hosting client uses, and this is the screen that has to look like
    // LabFox rather than like them. See issue #187.
    final issues = tester.getTopLeft(find.text('Issues'));
    final merge = tester.getTopLeft(find.text('Merge requests'));
    final projects = tester.getTopLeft(find.text('Projects'));

    expect(issues.dy, equals(merge.dy), reason: 'first two share a row');
    expect(issues.dx, lessThan(merge.dx), reason: 'and sit side by side');
    expect(projects.dy, greaterThan(issues.dy), reason: 'the next pair wraps');
    expect(projects.dx, equals(issues.dx), reason: 'aligned into a column');
  });

  testWidgets('sits on the brand navy', (tester) async {
    await tester.pumpWidget(_harness());

    final container = tester.widget<Container>(
      find
          .ancestor(of: find.text('My work'), matching: find.byType(Container))
          .first,
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(
      decoration.color,
      LabFoxColors.navy,
      reason:
          'the brand ground is what stops this reading as every other '
          'white-and-neutral client',
    );
  });

  testWidgets(
    'shows a count when there is one, and nothing when there is not',
    (tester) async {
      await tester.pumpWidget(_harness());

      expect(find.text('12'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      // Projects has no count. An unknown count must not render as zero.
      expect(find.text('0'), findsNothing);
    },
  );

  testWidgets('an odd number of destinations does not overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        destinations: [
          WorkDestination(
            icon: LabFoxIcons.issueOpen,
            label: 'Issues',
            onTap: () {},
          ),
          WorkDestination(
            icon: LabFoxIcons.inbox,
            label: 'To-do list',
            onTap: () {},
          ),
          WorkDestination(
            icon: LabFoxIcons.project,
            label: 'Projects',
            onTap: () {},
          ),
        ],
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Projects'), findsOneWidget);
  });

  testWidgets('every tile is reachable and meets the touch target', (
    tester,
  ) async {
    var tapped = 0;
    await tester.pumpWidget(
      _harness(
        destinations: [
          WorkDestination(
            icon: LabFoxIcons.issueOpen,
            label: 'Issues',
            onTap: () => tapped++,
          ),
          WorkDestination(
            icon: LabFoxIcons.inbox,
            label: 'To-do list',
            onTap: () => tapped++,
          ),
        ],
      ),
    );

    for (final label in ['Issues', 'To-do list']) {
      expect(
        tester
            .getSize(
              find
                  .ancestor(
                    of: find.text(label),
                    matching: find.byType(InkWell),
                  )
                  .first,
            )
            .height,
        greaterThanOrEqualTo(LabFoxSpacing.minTouchTarget),
      );
      await tester.tap(find.text(label));
    }
    expect(tapped, 2);
  });
}
