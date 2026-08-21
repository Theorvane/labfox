import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/settings/app_settings_providers.dart';
import '../../../l10n/app_localizations.dart';

/// App settings.
///
/// For 1.0 this is the account entry point and the open-source license notice,
/// which LabFox is obliged to expose (see THIRD_PARTY_NOTICES.md). Flutter
/// collects each pub dependency's license automatically, so [showLicensePage]
/// satisfies the attribution requirement.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// The name shown on the license page.
  static const _applicationName = 'LabFox';

  /// Copyright line shown on the license page. Not localized: it is a notice,
  /// not UI copy.
  static const _legalese = '© 2026 sloki9637 · Apache-2.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final version = ref.watch(appVersionProvider);

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
          _SectionHeader(l10n.settingsAppearance),
          RadioGroup<ThemeMode>(
            groupValue: themeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).set(value);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final mode in ThemeMode.values)
                  RadioListTile<ThemeMode>(
                    value: mode,
                    title: Text(switch (mode) {
                      ThemeMode.system => l10n.settingsThemeSystem,
                      ThemeMode.light => l10n.settingsThemeLight,
                      ThemeMode.dark => l10n.settingsThemeDark,
                    }),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          _SectionHeader(l10n.settingsAbout),
          ListTile(
            leading: const Icon(LabFoxIcons.document),
            title: Text(l10n.settingsVersion),
            trailing: Text(
              version.valueOrNull ?? '',
              style: LabFoxTextRoles.of(context).meta,
            ),
          ),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: LabFoxSpacing.md,
        right: LabFoxSpacing.md,
        top: LabFoxSpacing.md,
        bottom: LabFoxSpacing.xs,
      ),
      child: Text(label, style: LabFoxTextRoles.of(context).sectionHeader),
    );
  }
}
