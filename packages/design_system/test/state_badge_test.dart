import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, EntityState state, String label) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: StateBadge(state: state, label: label),
      ),
    ),
  );
}

void main() {
  testWidgets('open shows an open icon and label', (tester) async {
    await _pump(tester, EntityState.open, 'Open');
    expect(find.text('Open'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('merged shows the merge icon, distinct from closed', (
    tester,
  ) async {
    await _pump(tester, EntityState.merged, 'Merged');
    expect(find.text('Merged'), findsOneWidget);
    expect(find.byIcon(Icons.merge), findsOneWidget);
    expect(find.byIcon(Icons.cancel_outlined), findsNothing);
  });

  testWidgets('closed shows the closed icon', (tester) async {
    await _pump(tester, EntityState.closed, 'Closed');
    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
  });
}
