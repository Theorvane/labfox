import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reads the plain text of the log's selectable rich text.
String _allText(WidgetTester tester) {
  final widget = tester.widget<SelectableText>(find.byType(SelectableText));
  return widget.textSpan?.toPlainText() ?? '';
}

Future<void> _pump(WidgetTester tester, String trace) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: AnsiLogView(trace: trace)),
    ),
  );
}

void main() {
  testWidgets('renders trace text with the escape codes stripped', (
    tester,
  ) async {
    await _pump(
      tester,
      'Running\n\x1b[32mPASSED\x1b[0m\n\x1b[31mFAILED\x1b[0m',
    );
    final text = _allText(tester);

    expect(text, contains('Running'));
    expect(text, contains('PASSED'));
    expect(text, contains('FAILED'));
    // The escape bytes must not appear as text.
    expect(text, isNot(contains('\x1b')));
    expect(text, isNot(contains('[32m')));
  });

  testWidgets('empty trace renders nothing but does not throw', (tester) async {
    await _pump(tester, '');
    expect(tester.takeException(), isNull);
  });
}
