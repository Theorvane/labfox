import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../app/responsive.dart';
import '../../../l10n/app_localizations.dart';

/// Where the user's work starts.
///
/// A placeholder until M1 lands authentication: the shell exists so routing,
/// theming, localisation and the responsive split are all exercised end to end.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: ResponsiveLayout(
        mobile: (context) => const _EmptyState(),
        desktop: (context) => const Row(
          children: [
            SizedBox(width: 260, child: _NavigationPlaceholder()),
            VerticalDivider(width: 1),
            Expanded(child: _EmptyState()),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.homeEmptyState,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: LabFoxSpacing.md),
            const StateIndicator(
              state: LabFoxState.pending,
              label: 'No account connected',
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationPlaceholder extends StatelessWidget {
  const _NavigationPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(LabFoxSpacing.md),
      child: Align(alignment: Alignment.topLeft, child: Text('Navigation')),
    );
  }
}
