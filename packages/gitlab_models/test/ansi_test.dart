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

    test('consumes a 256-colour code without leaking its digits', () {
      // 38;5;n is extended colour; unsupported here, but its params must not
      // print as text.
      final spans = parseAnsi('\x1b[38;5;196mx\x1b[0m');
      expect(spans.map((s) => s.text).join(), 'x');
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
