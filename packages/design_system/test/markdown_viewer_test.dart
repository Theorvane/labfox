import 'package:design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester,
  String markdown, {
  void Function(String)? onTapLink,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MarkdownViewer(data: markdown, onTapLink: onTapLink),
      ),
    ),
  );
}

/// Collects the plain text across every Text/RichText the viewer produced.
String _allText(WidgetTester tester) {
  final buffer = StringBuffer();
  for (final w in tester.widgetList(find.byType(RichText))) {
    buffer.write((w as RichText).text.toPlainText());
  }
  return buffer.toString();
}

void main() {
  testWidgets('renders headings and paragraphs as text', (tester) async {
    await _pump(tester, '# Title\n\nHello world');
    final text = _allText(tester);
    expect(text, contains('Title'));
    expect(text, contains('Hello world'));
  });

  testWidgets('renders list items', (tester) async {
    await _pump(tester, '- one\n- two\n- three');
    final text = _allText(tester);
    expect(text, contains('one'));
    expect(text, contains('two'));
    expect(text, contains('three'));
  });

  testWidgets('renders a fenced code block verbatim', (tester) async {
    await _pump(tester, '```\nfinal x = 1;\n```');
    expect(_allText(tester), contains('final x = 1;'));
  });

  testWidgets('does not execute raw HTML — it shows as text or is dropped', (
    tester,
  ) async {
    // The safety requirement: raw HTML must never become a live widget. A
    // <script> tag must not run; at most it appears as literal text.
    await _pump(tester, 'before <script>alert(1)</script> after');
    final text = _allText(tester);
    expect(text, contains('before'));
    expect(text, contains('after'));
    // No widget named after the script tag exists; nothing executed.
    expect(find.byType(WidgetSpan), findsNothing);
  });

  testWidgets('a link is tappable and reports its href', (tester) async {
    String? tapped;
    await _pump(
      tester,
      '[docs](https://gitlab.com)',
      onTapLink: (href) => tapped = href,
    );

    final richText = tester.widget<RichText>(find.byType(RichText).first);
    // Find the link span and fire its recognizer.
    TextSpan? linkSpan;
    (richText.text as TextSpan).visitChildren((span) {
      if (span is TextSpan && span.recognizer is TapGestureRecognizer) {
        linkSpan = span;
        return false;
      }
      return true;
    });
    (linkSpan!.recognizer as TapGestureRecognizer).onTap!();

    expect(tapped, 'https://gitlab.com');
  });
}
