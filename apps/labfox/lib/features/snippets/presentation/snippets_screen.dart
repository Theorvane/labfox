import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/snippets_controller.dart';

/// A project's snippets, styled as compact GitLab work items.
class SnippetsScreen extends ConsumerWidget {
  const SnippetsScreen({required this.projectId, super.key});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snippets = ref.watch(projectSnippetsProvider(projectId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.snippetsTitle)),
      body: snippets.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _Retry(
          message: l10n.snippetsError,
          onRetry: () => ref.invalidate(projectSnippetsProvider(projectId)),
        ),
        data: (items) => items.isEmpty
            ? EmptyState(icon: LabFoxIcons.code, title: l10n.snippetsEmpty)
            : RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(projectSnippetsProvider(projectId).future),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final snippet = items[index];
                        return ListTile(
                          leading: const Icon(LabFoxIcons.code),
                          title: Text(snippet.title),
                          subtitle: snippet.description?.isNotEmpty == true
                              ? Text(
                                  snippet.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : (snippet.fileName == null
                                    ? null
                                    : Text(snippet.fileName!)),
                          trailing: const Icon(LabFoxIcons.chevron),
                          onTap: () => context.push(
                            Routes.snippet(projectId, snippet.id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class SnippetDetailScreen extends ConsumerWidget {
  const SnippetDetailScreen({
    required this.projectId,
    required this.snippetId,
    super.key,
  });

  final int projectId;
  final int snippetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = SnippetRef(projectId, snippetId);
    final snippet = ref.watch(projectSnippetProvider(key));
    return Scaffold(
      appBar: AppBar(
        title: Text(snippet.valueOrNull?.title ?? l10n.snippetsTitle),
      ),
      body: snippet.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _Retry(
          message: l10n.snippetError,
          onRetry: () => ref.invalidate(projectSnippetProvider(key)),
        ),
        data: (item) => _SnippetBody(projectId: projectId, snippet: item),
      ),
    );
  }
}

class _SnippetBody extends ConsumerWidget {
  const _SnippetBody({required this.projectId, required this.snippet});

  final int projectId;
  final Snippet snippet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final files = snippet.files;
    final content = files.length > 1
        ? null
        : ref.watch(snippetRawProvider(SnippetRef(projectId, snippet.id)));
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ListView(
          padding: const EdgeInsets.all(LabFoxSpacing.md),
          children: [
            Text(
              snippet.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (snippet.description?.isNotEmpty == true) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Text(snippet.description!),
            ],
            const SizedBox(height: LabFoxSpacing.lg),
            if (files.length > 1)
              for (final file in files)
                Card(
                  child: ListTile(
                    leading: const Icon(LabFoxIcons.file),
                    title: Text(file.path),
                    trailing: const Icon(LabFoxIcons.chevron),
                    onTap: () => context.push(
                      Routes.snippetFile(projectId, snippet.id, file.path),
                    ),
                  ),
                )
            else ...[
              Text(
                files.isNotEmpty
                    ? files.first.path
                    : (snippet.fileName ?? l10n.snippetContent),
                style: LabFoxTextRoles.of(context).sectionHeader,
              ),
              const SizedBox(height: LabFoxSpacing.sm),
              _Content(content: content!),
            ],
          ],
        ),
      ),
    );
  }
}

class SnippetFileScreen extends ConsumerWidget {
  const SnippetFileScreen({
    required this.projectId,
    required this.snippetId,
    required this.path,
    super.key,
  });

  final int projectId;
  final int snippetId;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(
      snippetFileProvider(SnippetFileRef(projectId, snippetId, path)),
    );
    return Scaffold(
      appBar: AppBar(title: Text(path.split('/').last)),
      body: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.md),
        child: _Content(content: content),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.content});
  final AsyncValue<String> content;

  @override
  Widget build(BuildContext context) => content.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (_, _) => Text(AppLocalizations.of(context).snippetContentError),
    data: (text) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SelectableText(
        text,
        style: const TextStyle(fontFamily: 'monospace'),
      ),
    ),
  );
}

class _Retry extends StatelessWidget {
  const _Retry({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message),
        const SizedBox(height: LabFoxSpacing.md),
        FilledButton(
          onPressed: onRetry,
          child: Text(AppLocalizations.of(context).retry),
        ),
      ],
    ),
  );
}
