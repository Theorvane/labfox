import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/ui/work_meta.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('timeAgo', () {
    final now = DateTime(2026, 8, 20, 12);

    test('formats sub-minute, minute, hour and day ages', () {
      expect(
        timeAgo(now.subtract(const Duration(seconds: 30)), now: now),
        'now',
      );
      expect(timeAgo(now.subtract(const Duration(minutes: 5)), now: now), '5m');
      expect(timeAgo(now.subtract(const Duration(hours: 3)), now: now), '3h');
      expect(timeAgo(now.subtract(const Duration(days: 6)), now: now), '6d');
    });

    test('formats week, month and year ages', () {
      expect(timeAgo(now.subtract(const Duration(days: 14)), now: now), '2w');
      expect(timeAgo(now.subtract(const Duration(days: 60)), now: now), '2mo');
      expect(timeAgo(now.subtract(const Duration(days: 400)), now: now), '1y');
    });

    test('clamps a future time to now', () {
      expect(timeAgo(now.add(const Duration(hours: 1)), now: now), 'now');
    });
  });

  group('repoPathFromWebUrl', () {
    test('extracts the project path before the /-/ marker', () {
      expect(
        repoPathFromWebUrl(
          'https://gitlab.com/group/proj/-/merge_requests/142',
        ),
        'group/proj',
      );
      expect(repoPathFromWebUrl('https://git.co/a/b/c/-/issues/9'), 'a/b/c');
    });

    test('returns null for null or unparseable input', () {
      expect(repoPathFromWebUrl(null), isNull);
      expect(repoPathFromWebUrl('https://gitlab.com/'), isNull);
    });
  });

  group('LabelChips', () {
    testWidgets('renders each label name as a chip', (tester) async {
      await _pump(
        tester,
        const LabelChips([
          Label(name: 'bug', color: '#d73a4a', textColor: '#ffffff'),
          Label(name: 'design', color: '#5319e7', textColor: '#ffffff'),
        ]),
      );

      expect(find.text('bug'), findsOneWidget);
      expect(find.text('design'), findsOneWidget);
    });

    testWidgets('caps the visible chips and shows a +N overflow', (
      tester,
    ) async {
      await _pump(
        tester,
        const LabelChips([
          Label(name: 'a'),
          Label(name: 'b'),
          Label(name: 'c'),
          Label(name: 'd'),
          Label(name: 'e'),
        ], max: 3),
      );

      expect(find.text('a'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
      // The fourth and fifth collapse into a count.
      expect(find.text('d'), findsNothing);
      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets('renders nothing when there are no labels', (tester) async {
      await _pump(tester, const LabelChips([]));
      expect(find.byType(Text), findsNothing);
    });
  });
}
