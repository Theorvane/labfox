import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/ui/link_opener.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/wiki_controllers.dart';
import 'widgets/wiki_error.dart';
import 'widgets/wiki_page_links.dart';

/// Reads one wiki page, with a page sidebar on wider screens.
class WikiPageScreen extends ConsumerWidget {
  const WikiPageScreen({
    required this.projectId,
    required this.slug,
    super.key,
  });

  final int projectId;
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pageRef = WikiPageRef(projectId: projectId, slug: slug);
    final page = ref.watch(wikiPageControllerProvider(pageRef));
    final wide = LabFoxBreakpoints.ofContext(context).isWide;
    final pages = wide
        ? ref.watch(wikiPagesControllerProvider(projectId))
        : null;
    final openLink = ref.watch(linkOpenerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(page.valueOrNull?.title ?? l10n.wikiTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.wiki(projectId)),
        ),
      ),
      body: page.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => WikiError(
          message: l10n.wikiPageError,
          onRetry: () => ref.invalidate(wikiPageControllerProvider(pageRef)),
        ),
        data: (item) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (wide)
                  SizedBox(
                    width: 280,
                    child: pages?.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, _) => WikiError(
                        message: l10n.wikiListError,
                        onRetry: () => ref.invalidate(
                          wikiPagesControllerProvider(projectId),
                        ),
                      ),
                      data: (items) => ListView(
                        children: [
                          WikiPageLinks(
                            pages: items,
                            selectedSlug: slug,
                            onOpen: (nextSlug) => context.go(
                              Routes.wikiPage(projectId, nextSlug),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (wide) const VerticalDivider(width: LabFoxSpacing.md),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(LabFoxSpacing.md),
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: LabFoxSpacing.md),
                      if (item.format == null || item.format == 'markdown')
                        MarkdownViewer(
                          data: item.content ?? '',
                          onTapLink: (href) {
                            final uri = Uri.tryParse(href);
                            if (uri == null) {
                              return;
                            }
                            if (uri.hasScheme) {
                              openLink(uri);
                            } else if (!uri.hasAuthority &&
                                uri.path.isNotEmpty) {
                              final linkedSlug = Uri(
                                path: slug,
                              ).resolveUri(uri).path;
                              if (linkedSlug.isNotEmpty) {
                                context.push(
                                  Routes.wikiPage(projectId, linkedSlug),
                                );
                              }
                            }
                          },
                        )
                      else
                        SelectableText(item.content ?? ''),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
