import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/project_labels_controller.dart';

/// Browses project labels and those inherited from ancestor groups.
class ProjectLabelsScreen extends ConsumerStatefulWidget {
  const ProjectLabelsScreen({required this.projectId, super.key});
  final int projectId;

  @override
  ConsumerState<ProjectLabelsScreen> createState() =>
      _ProjectLabelsScreenState();
}

class _ProjectLabelsScreenState extends ConsumerState<ProjectLabelsScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = ref.watch(projectLabelsControllerProvider(widget.projectId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.projectLabelsTitle),
        actions: [
          IconButton(
            icon: const Icon(LabFoxIcons.add),
            tooltip: l10n.projectLabelNew,
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => _CreateLabelDialog(projectId: widget.projectId),
            ),
          ),
        ],
      ),
      body: labels.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _Error(
          message: l10n.projectLabelsError,
          onRetry: () =>
              ref.invalidate(projectLabelsControllerProvider(widget.projectId)),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: LabFoxIcons.label,
              title: l10n.projectLabelsEmpty,
            );
          }
          final filtered = items
              .where(
                (item) =>
                    item.name.toLowerCase().contains(_search.toLowerCase()),
              )
              .toList();
          return RefreshIndicator(
            onRefresh: () => ref.refresh(
              projectLabelsControllerProvider(widget.projectId).future,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(LabFoxSpacing.md),
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(LabFoxIcons.search),
                          hintText: l10n.projectLabelSearch,
                        ),
                        onChanged: (value) => setState(() => _search = value),
                      ),
                    ),
                    if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(LabFoxSpacing.lg),
                        child: Text(
                          l10n.projectLabelsNoMatch,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    for (final label in filtered) ...[
                      ListTile(
                        leading: const Icon(LabFoxIcons.label),
                        title: Align(
                          alignment: Alignment.centerLeft,
                          child: LabelChips([
                            Label(
                              name: label.name,
                              color: label.color,
                              textColor: label.textColor,
                            ),
                          ]),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (label.description?.isNotEmpty == true)
                              Text(
                                label.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (!label.isProjectLabel)
                              Text(l10n.projectLabelGroup),
                          ],
                        ),
                        trailing: const Icon(LabFoxIcons.chevron),
                        onTap: () => context.push(
                          Routes.projectLabel(widget.projectId, label.id),
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Loads a label by project id and label id, independently of list state.
class ProjectLabelDetailScreen extends ConsumerWidget {
  const ProjectLabelDetailScreen({
    required this.projectId,
    required this.labelId,
    super.key,
  });
  final int projectId;
  final int labelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = ProjectLabelRef(projectId, labelId);
    final label = ref.watch(projectLabelProvider(key));
    return Scaffold(
      appBar: AppBar(
        title: Text(label.valueOrNull?.name ?? l10n.projectLabelsTitle),
      ),
      body: label.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _Error(
          message: l10n.projectLabelError,
          onRetry: () => ref.invalidate(projectLabelProvider(key)),
        ),
        data: (item) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.all(LabFoxSpacing.md),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: LabelChips([
                    Label(
                      name: item.name,
                      color: item.color,
                      textColor: item.textColor,
                    ),
                  ]),
                ),
                if (item.description?.isNotEmpty == true) ...[
                  const SizedBox(height: LabFoxSpacing.md),
                  SelectableText(item.description!),
                ],
                const SizedBox(height: LabFoxSpacing.md),
                Text(
                  item.isProjectLabel
                      ? l10n.projectLabelProject
                      : l10n.projectLabelGroup,
                ),
                const SizedBox(height: LabFoxSpacing.lg),
                _Count(
                  label: l10n.projectLabelOpenIssues,
                  count: item.openIssuesCount,
                ),
                _Count(
                  label: l10n.projectLabelClosedIssues,
                  count: item.closedIssuesCount,
                ),
                _Count(
                  label: l10n.projectLabelOpenMrs,
                  count: item.openMergeRequestsCount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    ).format(count);
    return ListTile(
      title: Text(label),
      trailing: Text(number, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _CreateLabelDialog extends ConsumerStatefulWidget {
  const _CreateLabelDialog({required this.projectId});
  final int projectId;

  @override
  ConsumerState<_CreateLabelDialog> createState() => _CreateLabelDialogState();
}

class _CreateLabelDialogState extends ConsumerState<_CreateLabelDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _color = TextEditingController();
  final _description = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _color.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_form.currentState!.validate() || _saving) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(projectLabelsControllerProvider(widget.projectId).notifier)
          .create(
            name: _name.text.trim(),
            color: _color.text.trim().toUpperCase(),
            description: _description.text.trim().isEmpty
                ? null
                : _description.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.projectLabelCreateError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.projectLabelNew),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: l10n.projectLabelName),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.projectLabelRequired
                      : null,
                ),
                TextFormField(
                  controller: _color,
                  decoration: InputDecoration(
                    labelText: l10n.projectLabelColor,
                  ),
                  validator: (value) =>
                      RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value?.trim() ?? '')
                      ? null
                      : l10n.projectLabelInvalidColor,
                ),
                TextFormField(
                  controller: _description,
                  decoration: InputDecoration(
                    labelText: l10n.projectLabelDescription,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _create,
          child: Text(l10n.projectLabelCreate),
        ),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});
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
