import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('parseAnsi', () {
    test('plain text is one default span', () {
      final spans = parseAnsi('hello world');
      expect(spans, hasLength(1));
      expect(spans.single.text, 'hello world');
      expect(spans.single.color, AnsiColor.defaultColor);
      expect(spans.single.bold, isFalse);
    });

    test('colours a run and resets', () {
      final spans = parseAnsi('a\x1b[31mred\x1b[0mb');
      expect(spans.map((s) => s.text), ['a', 'red', 'b']);
      expect(spans[0].color, AnsiColor.defaultColor);
      expect(spans[1].color, AnsiColor.red);
      expect(spans[2].color, AnsiColor.defaultColor);
    });

    test('applies bold and combined codes', () {
      final spans = parseAnsi('\x1b[1;32mok\x1b[0m');
      expect(spans.single.text, 'ok');
      expect(spans.single.bold, isTrue);
      expect(spans.single.color, AnsiColor.green);
    });

    test('bright colours use the bright variants', () {
      final spans = parseAnsi('\x1b[91mbright\x1b[0m');
      expect(spans.single.color, AnsiColor.brightRed);
    });

    test(
      'an unsupported extended foreground degrades to the default colour',
      () {
        // 38;5;n is extended colour; its params must not print, AND it must not
        // leave the previous colour in effect. red then 256 -> plain is default.
        final spans = parseAnsi('\x1b[31mred\x1b[38;5;196mplain');
        expect(spans.map((s) => s.text).toList(), ['red', 'plain']);
        expect(spans[0].color, AnsiColor.red);
        expect(spans[1].color, AnsiColor.defaultColor);
      },
    );

    test('a background colour code does not change the foreground', () {
      // 48;5;n sets a background LabFox ignores; the foreground must survive.
      final spans = parseAnsi('\x1b[32mgreen\x1b[48;5;196mstill');
      expect(spans[1].text, 'still');
      expect(spans[1].color, AnsiColor.green);
    });

    test('strips a non-SGR escape (erase line) instead of printing it', () {
      final spans = parseAnsi('keep\x1b[Kgone?');
      // The erase sequence is removed; surrounding text stays.
      expect(spans.map((s) => s.text).join(), 'keepgone?');
    });

    test('empty input yields no spans', () {
      expect(parseAnsi(''), isEmpty);
    });
  });
}
