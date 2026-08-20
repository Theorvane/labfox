import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';

/// The privacy policy, bundled with the app and rendered in place.
///
/// Ships as an asset so the policy the store links to is exactly the one the
/// installed version was built with — no browser, no network dependency.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsPrivacyPolicy)),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/PRIVACY.md'),
        builder: (context, snapshot) {
          final text = snapshot.data;
          if (text == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(LabFoxSpacing.md),
            child: MarkdownViewer(data: text),
          );
        },
      ),
    );
  }
}
