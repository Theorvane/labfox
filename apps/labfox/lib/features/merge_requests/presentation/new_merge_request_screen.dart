import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/merge_requests_controllers.dart';

/// A form to open a merge request. On success it replaces itself with the
/// created merge request's detail screen.
class NewMergeRequestScreen extends ConsumerStatefulWidget {
  const NewMergeRequestScreen({required this.projectId, super.key});

  final int projectId;

  @override
  ConsumerState<NewMergeRequestScreen> createState() =>
      _NewMergeRequestScreenState();
}

class _NewMergeRequestScreenState extends ConsumerState<NewMergeRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _source = TextEditingController();
  final _target = TextEditingController();
  final _title = TextEditingController();
  final _description = TextEditingController();

  @override
  void dispose() {
    _source.dispose();
    _target.dispose();
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      final mr = await ref
          .read(newMergeRequestControllerProvider.notifier)
          .submit(
            projectId: widget.projectId,
            sourceBranch: _source.text.trim(),
            targetBranch: _target.text.trim(),
            title: _title.text.trim(),
            description: _description.text.trim(),
          );
      if (!mounted) {
        return;
      }
      context.pushReplacement(Routes.mergeRequest(widget.projectId, mr.iid));
    } on GitLabException {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.newMrError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(newMergeRequestControllerProvider).isLoading;
    String? branch(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.newMrBranchRequired : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newMrTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(LabFoxSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _source,
                enabled: !busy,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: l10n.newMrSourceLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: branch,
              ),
              const SizedBox(height: LabFoxSpacing.md),
              TextFormField(
                controller: _target,
                enabled: !busy,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: l10n.newMrTargetLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: branch,
              ),
              const SizedBox(height: LabFoxSpacing.md),
              TextFormField(
                controller: _title,
                enabled: !busy,
                decoration: InputDecoration(
                  labelText: l10n.newMrTitleLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.newMrTitleRequired
                    : null,
              ),
              const SizedBox(height: LabFoxSpacing.md),
              TextFormField(
                controller: _description,
                enabled: !busy,
                minLines: 3,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: l10n.newMrDescriptionLabel,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: LabFoxSpacing.lg),
              FilledButton(
                onPressed: busy ? null : _submit,
                child: busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.newMrSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
