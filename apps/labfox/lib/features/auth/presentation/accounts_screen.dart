import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';

/// Lists the connected accounts, marks the active one, and switches, adds, or
/// removes accounts.
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(authControllerProvider.notifier);
    // Rebuild when the session changes so the active marker and list stay live.
    ref.watch(authControllerProvider);
    final accounts = notifier.accounts();
    final active = ref.watch(currentAccountProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountsTitle)),
      body: ListView(
        children: [
          for (final account in accounts)
            ListTile(
              leading: Icon(
                account.id == active?.id
                    ? Icons.check_circle
                    : Icons.account_circle_outlined,
                color: account.id == active?.id
                    ? LabFoxColors.success
                    : LabFoxColors.pending,
              ),
              title: Text(account.user.username),
              subtitle: Text(Uri.parse(account.instanceUrl).host),
              trailing: IconButton(
                icon: const Icon(Icons.logout),
                tooltip: l10n.accountRemove,
                onPressed: () => notifier.signOut(account),
              ),
              onTap: account.id == active?.id
                  ? null
                  : () => notifier.switchTo(account),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.accountAdd),
            onTap: () => context.go(Routes.addAccount),
          ),
        ],
      ),
    );
  }
}
