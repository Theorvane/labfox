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
class GitLabLabel extends StatelessWidget {
  const GitLabLabel({required this.name, this.color, super.key});

  final String name;

  /// Background colour as `#RRGGBB`; a theme default is used when absent.
  final String? color;

  @override
  Widget build(BuildContext context) {
    final background =
        _parse(color) ?? Theme.of(context).colorScheme.secondaryContainer;
    final foreground = _readableOn(background);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LabFoxSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(LabFoxRadius.pill),
      ),
      child: Text(
        name,
        style: LabFoxTextRoles.of(
          context,
        ).chipLabel.copyWith(color: foreground),
      ),
    );
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
