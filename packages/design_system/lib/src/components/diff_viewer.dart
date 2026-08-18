import 'package:flutter/material.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../tokens/spacing.dart';

/// Renders one file's unified diff.
///
/// Each hunk's lines are shown with a +/- gutter and add/remove colours; the
/// gutter carries the change type so it survives greyscale and colour
/// blindness. Long lines scroll horizontally rather than wrap, so alignment
/// holds. A binary file shows a placeholder instead of an empty body.
class DiffViewer extends StatelessWidget {
  const DiffViewer({
    required this.file,
    this.binaryLabel = 'Binary file',
    this.omittedLabel = 'Diff not shown',
    super.key,
  });

  final FileDiff file;

  /// Text shown for a binary file; the caller localizes it.
  final String binaryLabel;

  /// Text shown when GitLab omitted a text diff because it was too large or
  /// collapsed. Distinct from [binaryLabel] so a truncated source file is not
  /// mislabelled as binary.
  final String omittedLabel;

  @override
  Widget build(BuildContext context) {
    if (file.isBinary || file.isOmitted) {
      return Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.md),
        child: Text(
          file.isOmitted ? omittedLabel : binaryLabel,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final hunk in file.hunks) ...[
          _HunkHeader(header: hunk.header),
          for (final line in hunk.lines) _DiffLineRow(line: line),
        ],
      ],
    );
  }
}

class _HunkHeader extends StatelessWidget {
  const _HunkHeader({required this.header});

  final String header;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(
        horizontal: LabFoxSpacing.sm,
        vertical: 2,
      ),
      child: Text(
        header,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _DiffLineRow extends StatelessWidget {
  const _DiffLineRow({required this.line});

  final DiffLine line;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (background, marker) = switch (line.type) {
      DiffLineType.added => (
        isDark ? const Color(0x2600FF00) : const Color(0x1A1F8B4C),
        '+',
      ),
      DiffLineType.removed => (
        isDark ? const Color(0x26FF0000) : const Color(0x1AD1293D),
        '-',
      ),
      DiffLineType.context => (Colors.transparent, ' '),
    };

    return Container(
      color: background,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _gutter(line.oldLine),
            _gutter(line.newLine),
            SizedBox(
              width: 16,
              child: Text(
                marker,
                style: _mono(context),
                textAlign: TextAlign.center,
              ),
            ),
            Text('${line.text} ', style: _mono(context)),
          ],
        ),
      ),
    );
  }

  Widget _gutter(int? number) => Container(
    width: 44,
    padding: const EdgeInsets.symmetric(horizontal: LabFoxSpacing.xs),
    child: Text(
      number?.toString() ?? '',
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 12,
        color: Colors.grey,
      ),
    ),
  );

  TextStyle _mono(BuildContext context) => TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurface,
  );
}
