/// What a line in a diff represents.
enum DiffLineType { context, added, removed }

/// One line of a parsed diff, with its line number on each side.
///
/// A removed line has no number on the new side; an added line has none on the
/// old side. Context lines carry both.
class DiffLine {
  const DiffLine({
    required this.type,
    required this.text,
    this.oldLine,
    this.newLine,
  });

  final DiffLineType type;
  final String text;
  final int? oldLine;
  final int? newLine;
}

/// A contiguous block of changes with its position on each side.
class DiffHunk {
  const DiffHunk({
    required this.oldStart,
    required this.newStart,
    required this.header,
    required this.lines,
  });

  final int oldStart;
  final int newStart;

  /// The raw `@@ ... @@` header, kept for display.
  final String header;
  final List<DiffLine> lines;
}

final _hunkHeader = RegExp(r'^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@');

/// Parses a unified diff body into hunks of typed, numbered lines.
///
/// Expects the diff text GitLab returns for a file: hunk headers (`@@ ... @@`)
/// followed by context (` `), added (`+`), and removed (`-`) lines. The
/// no-newline marker (`\`) is metadata and is skipped.
List<DiffHunk> parseUnifiedDiff(String diff) {
  if (diff.isEmpty) {
    return const [];
  }

  final hunks = <DiffHunk>[];
  int? oldNo;
  int? newNo;
  List<DiffLine>? current;
  var oldStart = 0;
  var newStart = 0;
  var header = '';

  void flush() {
    if (current != null) {
      hunks.add(
        DiffHunk(
          oldStart: oldStart,
          newStart: newStart,
          header: header,
          lines: current,
        ),
      );
    }
  }

  for (final line in diff.split('\n')) {
    final match = _hunkHeader.firstMatch(line);
    if (match != null) {
      flush();
      oldStart = int.parse(match.group(1)!);
      newStart = int.parse(match.group(2)!);
      oldNo = oldStart;
      newNo = newStart;
      header = line;
      current = <DiffLine>[];
      continue;
    }
    if (current == null || line.isEmpty) {
      continue;
    }
    // The no-newline-at-end-of-file marker is metadata, not content.
    if (line.startsWith(r'\')) {
      continue;
    }

    final marker = line[0];
    final text = line.substring(1);
    switch (marker) {
      case '+':
        current.add(
          DiffLine(type: DiffLineType.added, text: text, newLine: newNo),
        );
        newNo = newNo! + 1;
      case '-':
        current.add(
          DiffLine(type: DiffLineType.removed, text: text, oldLine: oldNo),
        );
        oldNo = oldNo! + 1;
      case ' ':
        current.add(
          DiffLine(
            type: DiffLineType.context,
            text: text,
            oldLine: oldNo,
            newLine: newNo,
          ),
        );
        oldNo = oldNo! + 1;
        newNo = newNo! + 1;
      default:
        // Unrecognised prefix; ignore rather than guess.
        break;
    }
  }
  flush();
  return hunks;
}
