import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/wiki_controllers.dart';
import 'widgets/wiki_error.dart';
import 'widgets/wiki_page_links.dart';

/// Lists pages in a project wiki.
class WikiPagesScreen extends ConsumerWidget {
  const WikiPagesScreen({required this.projectId, super.key});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pages = ref.watch(wikiPagesControllerProvider(projectId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wikiTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.projectOverview(projectId)),
        ),
      ),
      body: pages.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => WikiError(
          message: l10n.wikiListError,
          onRetry: () => ref.invalidate(wikiPagesControllerProvider(projectId)),
        ),
        data: (items) => items.isEmpty
            ? Center(child: Text(l10n.wikiEmpty))
            : RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(wikiPagesControllerProvider(projectId).future),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Padding(
                          padding: const EdgeInsets.all(LabFoxSpacing.md),
                          child: Card.outlined(
                            margin: EdgeInsets.zero,
                            child: WikiPageLinks(
                              pages: items,
                              onOpen: (slug) => context.push(
                                Routes.wikiPage(projectId, slug),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
