import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';

Future<void> _pump(WidgetTester tester, CiStatus status, {String? label}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CiStatusIcon(status: status, label: label),
      ),
    ),
  );
}

void main() {
  testWidgets('success and failed use distinct icons', (tester) async {
    await _pump(tester, CiStatus.success);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await _pump(tester, CiStatus.failed);
    expect(find.byIcon(Icons.cancel), findsOneWidget);
  });

  testWidgets('running is distinguishable from pending', (tester) async {
    await _pump(tester, CiStatus.running);
    expect(find.byIcon(Icons.autorenew), findsOneWidget);
    expect(find.byIcon(Icons.schedule), findsNothing);
  });

  testWidgets('shows the label when given', (tester) async {
    await _pump(tester, CiStatus.failed, label: 'Failed');
    expect(find.text('Failed'), findsOneWidget);
  });
}
