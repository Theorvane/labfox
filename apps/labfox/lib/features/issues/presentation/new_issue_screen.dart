import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/issues_controllers.dart';

/// A form to open a new issue in a project. On success it replaces itself with
/// the created issue's detail screen.
class NewIssueScreen extends ConsumerStatefulWidget {
  const NewIssueScreen({required this.projectId, super.key});

  final int projectId;

  @override
  ConsumerState<NewIssueScreen> createState() => _NewIssueScreenState();
}

class _NewIssueScreenState extends ConsumerState<NewIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();

  @override
  void dispose() {
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
      final issue = await ref
          .read(newIssueControllerProvider.notifier)
          .submit(
            projectId: widget.projectId,
            title: _title.text.trim(),
            description: _description.text.trim(),
          );
      if (!mounted) {
        return;
      }
      // Replace the form with the new issue's detail.
      context.pushReplacement(Routes.issue(widget.projectId, issue.iid));
    } on GitLabException {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.newIssueError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(newIssueControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newIssueTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(LabFoxSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                enabled: !busy,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.newIssueTitleLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.newIssueTitleRequired
                    : null,
              ),
              const SizedBox(height: LabFoxSpacing.md),
              TextFormField(
                controller: _description,
                enabled: !busy,
                minLines: 4,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: l10n.newIssueDescriptionLabel,
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
                    : Text(l10n.newIssueSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
