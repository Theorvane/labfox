import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/responsive.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';

/// Where the user's work starts.
///
/// For this slice it confirms who is signed in and offers sign-out. Issues,
/// merge requests and pipelines land in later M1 and M2 pull requests.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final account = ref.watch(currentAccountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.signOut,
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: (context) => _Body(username: account?.user.username),
        desktop: (context) => Row(
          children: [
            const SizedBox(width: 260, child: _NavigationPlaceholder()),
            const VerticalDivider(width: 1),
            Expanded(child: _Body(username: account?.user.username)),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({this.username});

  final String? username;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (username != null)
              Text(
                l10n.homeSignedInAs(username!),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: LabFoxSpacing.md),
            Text(
              l10n.homeEmptyWork,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
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
