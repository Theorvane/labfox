import 'package:flutter/material.dart';

import '../tokens/spacing.dart';

/// A centred empty-list placeholder: a muted glyph, a bold headline, and an
/// optional supporting line and action.
///
/// One shape for "there is nothing here yet" across the app, so an empty
/// pipelines list reads the same as an empty search — a calm state, not a
/// broken one. The glyph is the caller's, drawn from the app's own icon set;
/// LabFox uses no third-party illustration for this.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    this.message,
    this.action,
    super.key,
  });

  final IconData icon;

  /// The headline, e.g. "No pipelines yet".
  final String title;

  /// An optional supporting line under the headline.
  final String? message;

  /// An optional action, typically a retry or create button.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: theme.hintColor),
            const SizedBox(height: LabFoxSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: LabFoxSpacing.xs),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: LabFoxSpacing.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
