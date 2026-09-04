import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/entitlement/entitlement.dart';
import '../../../core/entitlement/entitlement_providers.dart';
import '../../../core/entitlement/subscription_controller.dart';
import '../../../core/entitlement/subscription_links.dart';
import '../../../core/ui/link_opener.dart';
import '../../../l10n/app_localizations.dart';

/// What the subscription unlocks, and the two actions the stores require.
///
/// The price is never written here — it comes from the store already formatted
/// for the user's region and currency.
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entitlement = ref.watch(entitlementProvider);
    final offer = ref.watch(subscriptionOfferProvider);
    final action = ref.watch(subscriptionControllerProvider);
    final busy = action.isLoading;
    final open = ref.watch(linkOpenerProvider);
    final termsUrl = ref.watch(subscriptionTermsUrlProvider);
    final privacyUrl = ref.watch(subscriptionPrivacyUrlProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.subscriptionTitle)),
      body: ListView(
        padding: const EdgeInsets.all(LabFoxSpacing.md),
        children: [
          _Status(entitlement: entitlement),
          const SizedBox(height: LabFoxSpacing.md),
          Text(
            l10n.subscriptionPitch,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: LabFoxSpacing.md),
          for (final benefit in [
            l10n.subscriptionBenefitActions,
            l10n.subscriptionBenefitAccounts,
            l10n.subscriptionBenefitNotifications,
            l10n.subscriptionBenefitFavorites,
          ])
            _Benefit(benefit),
          const SizedBox(height: LabFoxSpacing.lg),
          if (!entitlement.isSubscribed)
            offer.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              // The offer provider never surfaces an error; a store that cannot
              // answer is reported as nothing to sell.
              error: (_, _) => Text(l10n.subscriptionUnavailable),
              data: (data) => data == null
                  ? Text(
                      l10n.subscriptionUnavailable,
                      style: LabFoxTextRoles.of(context).meta,
                    )
                  : FilledButton(
                      onPressed: busy
                          ? null
                          : () => ref
                                .read(subscriptionControllerProvider.notifier)
                                .subscribe(),
                      child: Text(l10n.subscriptionSubscribe(data.price)),
                    ),
            ),
          if (action.hasError) ...[
            const SizedBox(height: LabFoxSpacing.sm),
            Text(
              l10n.subscriptionError,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: LabFoxSpacing.sm),
          // Apple requires this to be reachable from the UI (Review Guideline
          // 3.1.1), and it is what a user on a new device needs. Shown on both
          // platforms so they behave alike.
          TextButton(
            onPressed: busy
                ? null
                : () => ref
                      .read(subscriptionControllerProvider.notifier)
                      .restore(),
            child: Text(l10n.subscriptionRestore),
          ),
          const SizedBox(height: LabFoxSpacing.md),
          // Guideline 3.1.2: the renewal terms and both links belong where the
          // purchase is made, not only in the store listing. A submission
          // without them is rejected before anyone opens the app.
          Text(
            l10n.subscriptionRenewalTerms,
            style: LabFoxTextRoles.of(context).meta,
          ),
          const SizedBox(height: LabFoxSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => open(Uri.parse(termsUrl)),
                child: Text(l10n.subscriptionTerms),
              ),
              TextButton(
                onPressed: () => open(Uri.parse(privacyUrl)),
                child: Text(l10n.subscriptionPrivacy),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.entitlement});

  final Entitlement entitlement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subscribed = entitlement.isSubscribed;
    return Row(
      children: [
        Icon(
          subscribed ? LabFoxIcons.check : LabFoxIcons.private,
          color: subscribed ? Theme.of(context).colorScheme.primary : null,
        ),
        const SizedBox(width: LabFoxSpacing.sm),
        Expanded(
          child: Text(
            subscribed ? l10n.subscriptionActive : l10n.subscriptionInactive,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LabFoxSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LabFoxIcons.check, size: 18),
          const SizedBox(width: LabFoxSpacing.sm),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
