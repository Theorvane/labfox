import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// A GitLab label chip.
///
/// GitLab supplies each label a background colour as a hex string. The
/// foreground is computed from it so the text stays readable on any colour;
/// colour is never the only signal, but a low-contrast chip is unreadable.
///
/// A label whose name contains `::` is **scoped**, and renders as two segments
/// the way gitlab.com does: the scope on the label's colour, the value on a
/// muted ground beside it. That is not decoration. Scoped labels are mutually
/// exclusive within their scope — an issue is `workflow::in dev` or
/// `workflow::in review`, never both — and the split is what tells a reader
/// that `workflow` is a dimension and the rest is its current value.
///
/// A single colon is not a scope. `Category:Secrets Manager` is an ordinary
/// label whose name happens to contain one, and splitting on `:` would break
/// every label like it.
class GitLabLabel extends StatelessWidget {
  const GitLabLabel({required this.name, this.color, super.key});

  final String name;

  /// Background colour as `#RRGGBB`; a theme default is used when absent.
  final String? color;

  /// GitLab's scope separator.
  static const _separator = '::';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = _parse(color) ?? scheme.secondaryContainer;
    final foreground = _readableOn(background);
    final style = LabFoxTextRoles.of(context).chipLabel;

    final scope = _scopeOf(name);
    if (scope == null) {
      return _Pill(
        background: background,
        child: Text(name, style: style.copyWith(color: foreground)),
      );
    }

    final (key, value) = scope;
    return _Pill(
      // The value segment sits on this ground, so the pill carries it and the
      // scope segment paints over its own half.
      background: scheme.surfaceContainerHighest,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: background),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: LabFoxSpacing.xs + 2,
                vertical: 2,
              ),
              child: Text(key, style: style.copyWith(color: foreground)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LabFoxSpacing.xs,
              2,
              LabFoxSpacing.sm,
              2,
            ),
            child: Text(value, style: style.copyWith(color: scheme.onSurface)),
          ),
        ],
      ),
    );
  }

  /// Splits `scope::value` at the first separator, or null when there is no
  /// scope. A separator at either end leaves one side empty, which is not a
  /// scope — GitLab would show such a name as an ordinary label.
  static (String, String)? _scopeOf(String name) {
    final at = name.indexOf(_separator);
    if (at <= 0) {
      return null;
    }
    final value = name.substring(at + _separator.length).trim();
    final key = name.substring(0, at).trim();
    if (key.isEmpty || value.isEmpty) {
      return null;
    }
    return (key, value);
  }

  static Color? _parse(String? hex) {
    if (hex == null) {
      return null;
    }
    final cleaned = hex.replaceFirst('#', '');
    if (cleaned.length != 6) {
      return null;
    }
    final value = int.tryParse(cleaned, radix: 16);
    return value == null ? null : Color(0xFF000000 | value);
  }

  /// Black or white, whichever reads better against [background].
  ///
  /// Uses WCAG relative luminance rather than a naive average, so mid-tones
  /// pick the correct side.
  static Color _readableOn(Color background) {
    double linear(double channel) {
      final s = channel / 255.0;
      return s <= 0.03928
          ? s / 12.92
          : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
    }

    final luminance =
        0.2126 * linear(background.r * 255) +
        0.7152 * linear(background.g * 255) +
        0.0722 * linear(background.b * 255);
    return luminance > 0.179 ? Colors.black : Colors.white;
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.background,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: LabFoxSpacing.sm,
      vertical: 2,
    ),
  });

  final Color background;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(LabFoxRadius.pill),
      child: DecoratedBox(
        decoration: BoxDecoration(color: background),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
