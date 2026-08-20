import 'package:flutter/material.dart';

/// The semantic text roles — the app's type hierarchy as one ladder.
///
/// Screens and components name the role they mean instead of picking a
/// `textTheme` slot and adjusting it in place, so the hierarchy
/// (headline > section header > row title > body > meta) is decided once and
/// reads the same everywhere. Every role derives from the theme's `TextTheme`,
/// so platform faces and theme colours carry through.
@immutable
class LabFoxTextRoles {
  const LabFoxTextRoles._({
    required this.pageHeadline,
    required this.sectionHeader,
    required this.rowTitle,
    required this.body,
    required this.meta,
    required this.chipLabel,
  });

  factory LabFoxTextRoles.of(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final muted = theme.colorScheme.onSurfaceVariant;
    return LabFoxTextRoles._(
      pageHeadline: text.headlineSmall!,
      sectionHeader: text.titleMedium!,
      rowTitle: text.titleSmall!.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      body: text.bodyMedium!,
      meta: text.bodySmall!.copyWith(color: muted),
      chipLabel: text.labelSmall!.copyWith(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.2,
      ),
    );
  }

  /// The page's own headline — a project's name above its overview.
  final TextStyle pageHeadline;

  /// A section heading above a group of rows ("My work", "Recent", "Code").
  /// Deliberately a full step above [rowTitle] in size and weight.
  final TextStyle sectionHeader;

  /// The title of a list or launcher row.
  final TextStyle rowTitle;

  /// Plain running text.
  final TextStyle body;

  /// Muted metadata under or beside a title — numbers, paths, times.
  final TextStyle meta;

  /// The label inside a pill, badge, or label chip. Colour comes from the
  /// chip; this only fixes the metrics so all chips agree.
  final TextStyle chipLabel;
}
