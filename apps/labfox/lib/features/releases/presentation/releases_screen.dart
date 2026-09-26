import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/releases_controller.dart';

/// Project Releases, newest published first.
class ReleasesScreen extends ConsumerWidget {
  const ReleasesScreen({required this.projectId, super.key});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final releases = ref.watch(releaseListControllerProvider(projectId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.releasesTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.projectOverview(projectId)),
        ),
      ),
      body: releases.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.releasesError),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(releaseListControllerProvider(projectId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (page) => page.items.isEmpty
            ? Center(child: Text(l10n.releasesEmpty))
            : RefreshIndicator(
                onRefresh: () => ref.refresh(
                  releaseListControllerProvider(projectId).future,
                ),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Padding(
                          padding: const EdgeInsets.all(LabFoxSpacing.md),
                          child: Card.outlined(
                            margin: EdgeInsets.zero,
                            child: Column(
                              children: [
                                for (final release in page.items)
                                  ListTile(
                                    leading: const Icon(LabFoxIcons.release),
                                    title: Text(release.name),
                                    subtitle: Text(
                                      [
                                        release.tagName,
                                        if (release.releasedAt != null)
                                          DateFormat.yMMMd(
                                            Localizations.localeOf(
                                              context,
                                            ).toString(),
                                          ).format(release.releasedAt!),
                                      ].join(' · '),
                                    ),
                                    trailing: release.upcomingRelease == true
                                        ? Chip(
                                            label: Text(l10n.releaseUpcoming),
                                          )
                                        : const Icon(LabFoxIcons.chevron),
                                    onTap: () => context.push(
                                      Routes.release(
                                        projectId,
                                        release.tagName,
                                      ),
                                    ),
                                  ),
                                if (page.hasMore)
                                  TextButton(
                                    onPressed: () => ref
                                        .read(
                                          releaseListControllerProvider(
                                            projectId,
                                          ).notifier,
                                        )
                                        .loadMore(),
                                    child: Text(l10n.releaseLoadMore),
                                  ),
                              ],
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
