import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';

/// App settings.
///
/// For 1.0 this is the account entry point and the open-source license notice,
/// which LabFox is obliged to expose (see THIRD_PARTY_NOTICES.md). Flutter
/// collects each pub dependency's license automatically, so [showLicensePage]
/// satisfies the attribution requirement.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// The name shown on the license page.
  static const _applicationName = 'LabFox';

  /// Copyright line shown on the license page. Not localized: it is a notice,
  /// not UI copy.
  static const _legalese = '© 2026 sloki9637 · Apache-2.0';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(LabFoxIcons.account),
            title: Text(l10n.settingsAccounts),
            trailing: const Icon(LabFoxIcons.chevron),
            onTap: () => context.go(Routes.accounts),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(LabFoxIcons.document),
            title: Text(l10n.settingsLicenses),
            trailing: const Icon(LabFoxIcons.chevron),
            onTap: () => showLicensePage(
              context: context,
              applicationName: _applicationName,
              applicationLegalese: _legalese,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Text(
              _legalese,
              textAlign: TextAlign.center,
              style: LabFoxTextRoles.of(context).meta,
            ),
          ),
        ],
      ),
    );
  }
}
