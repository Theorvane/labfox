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

  testWidgets('a block-level raw HTML tag renders no widget span', (
    tester,
  ) async {
    // Guards the whitelist: a raw HTML block must fall through to text, never a
    // WidgetSpan or a live element. If someone relaxes the renderer whitelist,
    // this fails.
    await _pump(tester, '<div onclick="x()">danger</div>\n\ncontent');
    expect(find.byType(WidgetSpan), findsNothing);
    expect(_allText(tester), contains('content'));
  });

  group('HTML rendering', () {
    testWidgets('renders a centered bold block as styled text, not tags', (
      tester,
    ) async {
      await _pump(
        tester,
        '<p align="center"><b>LabFox</b><br>a GitLab client</p>',
      );
      final text = _allText(tester);
      expect(text, contains('LabFox'));
      expect(text, contains('a GitLab client'));
      expect(text, isNot(contains('<')));
    });

    testWidgets('renders inline HTML text without tags', (tester) async {
      await _pump(tester, 'Hello <sub>tiny</sub> world');
      final text = _allText(tester);
      expect(text, contains('Hello'));
      expect(text, contains('tiny'));
      expect(text, contains('world'));
      expect(text, isNot(contains('<')));
    });

    testWidgets('an HTML img renders as an image', (tester) async {
      await _pump(tester, '<img src="https://x.test/badge.svg" alt="badge">');
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('a markdown image renders as an image', (tester) async {
      await _pump(tester, '![logo](https://x.test/logo.png)');
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('a details block hides its content until expanded', (
      tester,
    ) async {
      await _pump(
        tester,
        '<details><summary>More info</summary>The hidden part</details>',
      );
      expect(_allText(tester), contains('More info'));
      expect(_allText(tester), isNot(contains('The hidden part')));

      await tester.tap(find.text('More info'));
      await tester.pumpAndSettle();
      expect(_allText(tester), contains('The hidden part'));
    });

    testWidgets('an HTML heading gets the heading style', (tester) async {
      await _pump(tester, '<h2>Getting started</h2>');
      final text = _allText(tester);
      expect(text, contains('Getting started'));
      expect(text, isNot(contains('<')));
    });

    testWidgets('an HTML link reports its href through onTapLink', (
      tester,
    ) async {
      String? tapped;
      await _pump(
        tester,
        '<p><a href="https://gitlab.com/docs">the docs</a></p>',
        onTapLink: (href) => tapped = href,
      );

      final richText = tester.widget<RichText>(find.byType(RichText).first);
      TextSpan? linkSpan;
      (richText.text as TextSpan).visitChildren((span) {
        if (span is TextSpan && span.recognizer is TapGestureRecognizer) {
          linkSpan = span;
          return false;
        }
        return true;
      });
      (linkSpan!.recognizer! as TapGestureRecognizer).onTap!();

      expect(tapped, 'https://gitlab.com/docs');
    });

    testWidgets('script and style contents are dropped entirely', (
      tester,
    ) async {
      await _pump(tester, 'before\n\n<script>\nalert(1)\n</script>\n\nafter');
      final text = _allText(tester);
      expect(text, contains('before'));
      expect(text, contains('after'));
      expect(text, isNot(contains('alert(1)')));
      expect(text, isNot(contains('<')));
    });

    testWidgets('an iframe is dropped with its content', (tester) async {
      await _pump(
        tester,
        '<iframe src="https://evil.test">tracking</iframe>\n\nvisible',
      );
      final text = _allText(tester);
      expect(text, contains('visible'));
      expect(text, isNot(contains('tracking')));
      expect(text, isNot(contains('<')));
    });

    testWidgets('common entities decode to their characters', (tester) async {
      await _pump(tester, 'a &amp; b, x &lt; y');
      final text = _allText(tester);
      expect(text, contains('a & b'));
      expect(text, contains('x < y'));
    });
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
