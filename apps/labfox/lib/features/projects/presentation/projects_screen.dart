import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/projects_controller.dart';

/// The signed-in account's projects.
class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final projects = ref.watch(projectsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.projectsTitle)),
      body: projects.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ProjectsError(
          message: l10n.projectsError,
          onRetry: () =>
              ref.read(projectsControllerProvider.notifier).refresh(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(LabFoxSpacing.lg),
                child: Text(l10n.projectsEmpty, textAlign: TextAlign.center),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(projectsControllerProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) => _tile(context, items[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _tile(BuildContext context, Project project) {
    return ProjectTile(
      name: project.name,
      path: project.pathWithNamespace,
      description: project.description,
      starCount: project.starCount,
      avatarUrl: project.avatarUrl,
      visibility: project.visibility,
      onTap: () => context.go(Routes.projectOverview(project.id)),
    );
  }
}

class _ProjectsError extends StatelessWidget {
  const _ProjectsError({required this.message, required this.onRetry});

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
