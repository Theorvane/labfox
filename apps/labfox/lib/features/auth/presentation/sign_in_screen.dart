import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';

/// Connects an account with an instance URL and a Personal Access Token.
///
/// The instance URL is a field, not a fixed value: gitlab.com is only the
/// prefilled suggestion, never assumed, so self-hosted works the same way.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _instanceController = TextEditingController(text: 'https://gitlab.com');
  final _tokenController = TextEditingController();
  bool _obscureToken = true;

  @override
  void dispose() {
    _instanceController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await ref
        .read(authControllerProvider.notifier)
        .signIn(
          instanceUrl: _instanceController.text.trim(),
          token: _tokenController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final error = authState.hasError
        ? _messageFor(authState.error!, l10n)
        : null;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(LabFoxSpacing.lg),
          child: ConstrainedBox(
            // Keep the form readable on a wide desktop window rather than
            // stretching a text field across the whole screen.
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.signInTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: LabFoxSpacing.lg),
                  TextFormField(
                    controller: _instanceController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: l10n.signInInstanceLabel,
                      hintText: 'https://gitlab.com',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => _validateInstance(value, l10n),
                  ),
                  const SizedBox(height: LabFoxSpacing.md),
                  TextFormField(
                    controller: _tokenController,
                    enabled: !isLoading,
                    obscureText: _obscureToken,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      labelText: l10n.signInTokenLabel,
                      helperText: l10n.signInTokenHelp,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureToken
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        tooltip: l10n.signInTokenToggle,
                        onPressed: () =>
                            setState(() => _obscureToken = !_obscureToken),
                      ),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? l10n.signInTokenRequired
                        : null,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: LabFoxSpacing.md),
                    Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: LabFoxSpacing.lg),
                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.signInSubmit),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateInstance(String? value, AppLocalizations l10n) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return l10n.signInInstanceRequired;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.isScheme('https') || uri.host.isEmpty) {
      return l10n.signInInstanceInvalid;
    }
    return null;
  }

  /// Turns a domain exception into advice the user can act on.
  ///
  /// A rejected token, a missing scope, and an unreachable instance each get a
  /// different message, because the fix for each is different.
  String _messageFor(Object error, AppLocalizations l10n) {
    return switch (error) {
      GitLabAuthException() => l10n.signInErrorToken,
      GitLabForbiddenException() => l10n.signInErrorScope,
      GitLabConnectionException() => l10n.signInErrorUnreachable,
      GitLabException() => l10n.signInErrorGeneric,
      _ => l10n.signInErrorGeneric,
    };
  }
}
