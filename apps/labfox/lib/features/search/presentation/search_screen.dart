import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../data/search_repository.dart';
import 'controllers/search_controllers.dart';

/// Global search across projects, issues and merge requests.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _field = TextEditingController();
  Timer? _debounce;
  SearchScope _scope = SearchScope.projects;
  String _text = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _field.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    // Wait for a pause in typing so each keystroke does not fire a request.
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _text = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = SearchQuery(scope: _scope, text: _text);
    final results = ref.watch(searchControllerProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LabFoxSpacing.md,
                  vertical: LabFoxSpacing.sm,
                ),
                child: TextField(
                  controller: _field,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: _onChanged,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: l10n.searchHint,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: LabFoxSpacing.md,
                  right: LabFoxSpacing.md,
                  bottom: LabFoxSpacing.sm,
                ),
                child: SegmentedButton<SearchScope>(
                  segments: [
                    ButtonSegment(
                      value: SearchScope.projects,
                      label: Text(l10n.searchScopeProjects),
                    ),
                    ButtonSegment(
                      value: SearchScope.issues,
                      label: Text(l10n.searchScopeIssues),
                    ),
                    ButtonSegment(
                      value: SearchScope.mergeRequests,
                      label: Text(l10n.searchScopeMergeRequests),
                    ),
                  ],
                  selected: {_scope},
                  onSelectionChanged: (s) => setState(() => _scope = s.first),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _text.trim().isEmpty
          ? Center(child: Text(l10n.searchInitial))
          : results.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorState(
                message: l10n.searchError,
                onRetry: () => ref.invalidate(searchControllerProvider(query)),
              ),
              data: (page) {
                if (page.items.isEmpty) {
                  return Center(child: Text(l10n.searchEmpty));
                }
                return ListView.separated(
                  itemCount: page.items.length + (page.hasMore ? 1 : 0),
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index >= page.items.length) {
                      return _LoadMoreFooter(
                        page: page,
                        onLoadMore: () => ref
                            .read(searchControllerProvider(query).notifier)
                            .loadMore(),
                      );
                    }
                    return _ResultTile(item: page.items[index]);
                  },
                );
              },
            ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.item});

  final Object item;

  @override
  Widget build(BuildContext context) {
    final item = this.item;
    if (item is Project) {
      return ProjectTile(
        name: item.name,
        path: item.pathWithNamespace,
        description: item.description,
        starCount: item.starCount,
        onTap: () => context.go(Routes.projectOverview(item.id)),
      );
    }
    if (item is Issue) {
      final projectId = item.projectId;
      return ListTile(
        leading: const Icon(Icons.adjust),
        title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text('#${item.iid}'),
        onTap: projectId == null
            ? null
            : () => context.go(Routes.issue(projectId, item.iid)),
      );
    }
    if (item is MergeRequest) {
      final projectId = item.projectId;
      return ListTile(
        leading: const Icon(Icons.merge_outlined),
        title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text('!${item.iid}'),
        onTap: projectId == null
            ? null
            : () => context.go(Routes.mergeRequest(projectId, item.iid)),
      );
    }
    return const SizedBox.shrink();
  }
}

/// The footer under the results: a load-more button, a spinner while the next
/// page loads, or a message with a retry when it failed. The button is
/// disabled while a page is in flight so it cannot be fired twice.
class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({required this.page, required this.onLoadMore});

  final SearchResults page;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (page.loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(LabFoxSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(LabFoxSpacing.md),
      child: Column(
        children: [
          if (page.loadMoreFailed) ...[
            Text(
              l10n.searchError,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: LabFoxSpacing.sm),
          ],
          OutlinedButton(
            onPressed: onLoadMore,
            child: Text(page.loadMoreFailed ? l10n.retry : l10n.searchLoadMore),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: LabFoxSpacing.md),
            FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
