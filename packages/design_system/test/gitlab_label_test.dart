import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Finds the label's Text so its computed foreground colour can be checked.
Color _textColor(WidgetTester tester) {
  return tester.widget<Text>(find.text('bug')).style!.color!;
}

Future<void> _pump(WidgetTester tester, String? color) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: GitLabLabel(name: 'bug', color: color),
      ),
    ),
  );
}

void main() {
  testWidgets('renders the label text', (tester) async {
    await _pump(tester, '#ff0000');
    expect(find.text('bug'), findsOneWidget);
  });

  testWidgets('uses white text on a dark background', (tester) async {
    await _pump(tester, '#1f1f1f');
    expect(_textColor(tester), Colors.white);
  });

  testWidgets('uses black text on a light background', (tester) async {
    await _pump(tester, '#f5f5f5');
    expect(_textColor(tester), Colors.black);
  });

  testWidgets('tolerates a malformed colour without throwing', (tester) async {
    // A bad hex must not crash the list; it falls back to a theme colour.
    await _pump(tester, 'not-a-color');
    expect(find.text('bug'), findsOneWidget);
  });
}
