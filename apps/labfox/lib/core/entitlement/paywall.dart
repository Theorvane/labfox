import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../l10n/app_localizations.dart';
import 'entitlement_providers.dart';

/// What a free user just tried to do.
///
/// Only exists to pick the sentence the sheet opens with: an offer that names
/// the thing the user reached for converts, and a generic "upgrade" does not.
enum PaidFeature {
  mergeRequestActions,
  pipelineActions,
  multipleAccounts,
  favorites,
}

/// Runs [action] for a subscriber; offers the subscription to anyone else.
///
/// Every paid action goes through here, so the boundary is one function rather
/// than a condition repeated at each call site, and a free user always gets an
/// explanation and a way forward instead of a disabled button with no reason.
///
/// Free platforms report [Entitlement.subscribed] (`monetization.md` §1), so
/// this is transparent on Windows, macOS, and Linux.
Future<void> runSubscribed(
  BuildContext context,
  WidgetRef ref, {
  required PaidFeature feature,
  required Future<void> Function() action,
}) async {
  if (ref.read(entitlementProvider).isSubscribed) {
    await action();
    return;
  }
  await showPaywall(context, feature);
}

/// The offer itself: what is locked, and the two ways out of the sheet.
Future<void> showPaywall(BuildContext context, PaidFeature feature) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.paywallTitle,
              style: LabFoxTextRoles.of(sheetContext).sectionHeader,
            ),
            const SizedBox(height: LabFoxSpacing.sm),
            Text(_reason(l10n, feature)),
            const SizedBox(height: LabFoxSpacing.lg),
            FilledButton(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.push(Routes.subscription);
              },
              child: Text(l10n.paywallSubscribe),
            ),
            TextButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: Text(l10n.paywallNotNow),
            ),
          ],
        ),
      ),
    ),
  );
}

String _reason(AppLocalizations l10n, PaidFeature feature) => switch (feature) {
  PaidFeature.mergeRequestActions => l10n.paywallMergeRequestActions,
  PaidFeature.pipelineActions => l10n.paywallPipelineActions,
  PaidFeature.multipleAccounts => l10n.paywallAccounts,
  PaidFeature.favorites => l10n.paywallFavorites(freeFavoriteLimit),
};

/// How many projects a free user may keep as favorites.
///
/// Small enough that someone with a real project list feels the ceiling, large
/// enough to be useful on its own — the free tier has to stay worth keeping
/// installed (`monetization.md` §2).
const freeFavoriteLimit = 3;
