import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

void main() {
  testWidgets('shows name and full path', (tester) async {
    await _pump(
      tester,
      const ProjectTile(name: 'backend', path: 'youthpick/backend'),
    );

    expect(find.text('backend'), findsOneWidget);
    expect(find.text('youthpick/backend'), findsOneWidget);
  });

  testWidgets('hides the star count when zero', (tester) async {
    await _pump(
      tester,
      const ProjectTile(name: 'x', path: 'a/x', starCount: 0),
    );
    expect(find.byIcon(Icons.star_outline), findsNothing);
  });

  testWidgets('shows the star count when positive', (tester) async {
    await _pump(
      tester,
      const ProjectTile(name: 'x', path: 'a/x', starCount: 7),
    );
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('calls onTap', (tester) async {
    var tapped = false;
    await _pump(
      tester,
      ProjectTile(name: 'x', path: 'a/x', onTap: () => tapped = true),
    );
    await tester.tap(find.byType(ProjectTile));
    expect(tapped, isTrue);
  });
}
