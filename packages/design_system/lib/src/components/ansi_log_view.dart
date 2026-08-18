import 'package:flutter/material.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';

/// Renders a job trace with its ANSI colours, in a monospace, scrollable view.
///
/// The raw text is parsed into styled spans and drawn as selectable rich text.
/// Colours are theme-aware so the log stays legible in light and dark. Long
/// lines scroll horizontally rather than wrap, preserving alignment.
class AnsiLogView extends StatelessWidget {
  const AnsiLogView({required this.trace, super.key});

  final String trace;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spans = parseAnsi(trace);

    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF0B1220) : const Color(0xFFF6F8FA),
      padding: const EdgeInsets.all(LabFoxSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText.rich(
          TextSpan(
            children: [
              for (final span in spans)
                TextSpan(
                  text: span.text,
                  style: TextStyle(
                    color: _resolve(span.color, isDark, Theme.of(context)),
                    fontWeight: span.bold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
            ],
          ),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  /// Maps an ANSI colour to a theme-aware [Color]. The default colour follows
  /// the surface foreground so plain log text reads normally in both themes.
  Color _resolve(AnsiColor color, bool isDark, ThemeData theme) {
    Color pick(Color light, Color dark) => isDark ? dark : light;
    return switch (color) {
      AnsiColor.defaultColor => theme.colorScheme.onSurface,
      AnsiColor.black => pick(const Color(0xFF24292F), const Color(0xFF6E7681)),
      AnsiColor.red || AnsiColor.brightRed => pick(
        const Color(0xFFCF222E),
        const Color(0xFFFF7B72),
      ),
      AnsiColor.green || AnsiColor.brightGreen => pick(
        const Color(0xFF116329),
        const Color(0xFF3FB950),
      ),
      AnsiColor.yellow || AnsiColor.brightYellow => pick(
        const Color(0xFF9A6700),
        const Color(0xFFD29922),
      ),
      AnsiColor.blue || AnsiColor.brightBlue => pick(
        const Color(0xFF0969DA),
        const Color(0xFF58A6FF),
      ),
      AnsiColor.magenta || AnsiColor.brightMagenta => pick(
        const Color(0xFF8250DF),
        const Color(0xFFBC8CFF),
      ),
      AnsiColor.cyan || AnsiColor.brightCyan => pick(
        const Color(0xFF1B7C83),
        const Color(0xFF39C5CF),
      ),
      AnsiColor.white || AnsiColor.brightWhite => pick(
        const Color(0xFF6E7781),
        const Color(0xFFB1BAC4),
      ),
      AnsiColor.brightBlack => LabFoxColors.pending,
    };
  }
}
