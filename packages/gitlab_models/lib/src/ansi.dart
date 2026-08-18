/// A terminal colour from an ANSI SGR code.
///
/// The 16 basic colours plus a default. Extended (256/truecolor) codes are
/// consumed but not represented — CI logs overwhelmingly use the basic set, and
/// an unsupported colour degrades to [defaultColor] rather than printing its
/// escape digits.
enum AnsiColor {
  defaultColor,
  black,
  red,
  green,
  yellow,
  blue,
  magenta,
  cyan,
  white,
  brightBlack,
  brightRed,
  brightGreen,
  brightYellow,
  brightBlue,
  brightMagenta,
  brightCyan,
  brightWhite,
}

/// A run of log text sharing one style.
class AnsiSpan {
  const AnsiSpan({required this.text, required this.color, required this.bold});

  final String text;
  final AnsiColor color;
  final bool bold;
}

const _basic = [
  AnsiColor.black,
  AnsiColor.red,
  AnsiColor.green,
  AnsiColor.yellow,
  AnsiColor.blue,
  AnsiColor.magenta,
  AnsiColor.cyan,
  AnsiColor.white,
];

const _bright = [
  AnsiColor.brightBlack,
  AnsiColor.brightRed,
  AnsiColor.brightGreen,
  AnsiColor.brightYellow,
  AnsiColor.brightBlue,
  AnsiColor.brightMagenta,
  AnsiColor.brightCyan,
  AnsiColor.brightWhite,
];

// Matches any ANSI escape sequence: CSI (ESC [ ... final-byte) or a lone ESC.
final _escape = RegExp(r'\x1b\[[0-9;?]*[ -/]*[@-~]|\x1b[@-Z\\-_]');

/// Parses a job trace into styled spans.
///
/// SGR sequences (`ESC[…m`) update the colour and bold state; every other
/// escape (cursor moves, line erase) is stripped so it never renders as raw
/// text. Newlines stay inside the span text.
List<AnsiSpan> parseAnsi(String input) {
  if (input.isEmpty) {
    return const [];
  }

  final spans = <AnsiSpan>[];
  final buffer = StringBuffer();
  var color = AnsiColor.defaultColor;
  var bold = false;

  void flush() {
    if (buffer.isNotEmpty) {
      spans.add(AnsiSpan(text: buffer.toString(), color: color, bold: bold));
      buffer.clear();
    }
  }

  var index = 0;
  for (final match in _escape.allMatches(input)) {
    buffer.write(input.substring(index, match.start));
    index = match.end;

    final seq = match.group(0)!;
    if (!seq.endsWith('m')) {
      // Not an SGR sequence (erase, cursor, etc.). Drop it.
      continue;
    }
    // Style is about to change; close the current run first.
    flush();
    final params = seq.substring(2, seq.length - 1);
    (color, bold) = _applySgr(params, color, bold);
  }
  buffer.write(input.substring(index));
  flush();
  return spans;
}

(AnsiColor, bool) _applySgr(String params, AnsiColor color, bool bold) {
  final codes = (params.isEmpty ? '0' : params).split(';');
  var i = 0;
  while (i < codes.length) {
    final code = int.tryParse(codes[i]) ?? 0;
    switch (code) {
      case 0:
        color = AnsiColor.defaultColor;
        bold = false;
      case 1:
        bold = true;
      case 22:
        bold = false;
      case 39:
        color = AnsiColor.defaultColor;
      case >= 30 && <= 37:
        color = _basic[code - 30];
      case >= 90 && <= 97:
        color = _bright[code - 90];
      case 38 || 48:
        // Extended colour: consume its parameters so they do not print —
        // 38;5;n (256) or 38;2;r;g;b (truecolor). LabFox does not render these,
        // so an extended *foreground* (38) degrades to the default colour rather
        // than leaving the previous one in effect; a *background* (48) is
        // ignored entirely and must not touch the foreground.
        if (code == 38) {
          color = AnsiColor.defaultColor;
        }
        if (i + 1 < codes.length && codes[i + 1] == '5') {
          i += 2;
        } else if (i + 1 < codes.length && codes[i + 1] == '2') {
          i += 4;
        }
      default:
        break;
    }
    i++;
  }
  return (color, bold);
}
