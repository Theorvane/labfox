import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';

import '../../../l10n/app_localizations.dart';
import 'controllers/file_controller.dart';

/// Shows one file's contents as monospace text.
///
/// A binary file is not rendered as text — it would be noise — so a placeholder
/// stands in. Syntax highlighting, copy and raw actions are follow-ups.
class FileViewerScreen extends ConsumerWidget {
  const FileViewerScreen({
    required this.projectId,
    required this.ref,
    required this.path,
    super.key,
  });

  final int projectId;
  final String ref;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final l10n = AppLocalizations.of(context);
    final fileRef = FileRef(projectId: projectId, ref: ref, path: path);
    final file = widgetRef.watch(fileControllerProvider(fileRef));
    final name = path.split('/').last;

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: file.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.fileError, textAlign: TextAlign.center),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton(
                  onPressed: () =>
                      widgetRef.invalidate(fileControllerProvider(fileRef)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (result) => _body(context, l10n, result),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n,
    RepositoryFile? result,
  ) {
    if (result == null) {
      return Center(child: Text(l10n.fileNotFound));
    }
    if (result.isBinary) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(LabFoxSpacing.lg),
          child: Text(l10n.fileBinary, textAlign: TextAlign.center),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(LabFoxSpacing.md),
      child: SingleChildScrollView(
        // Long lines scroll horizontally rather than wrapping, so code keeps its
        // shape.
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          result.text ?? '',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
