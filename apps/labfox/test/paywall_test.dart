import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/core/entitlement/entitlement.dart';
import 'package:labfox/core/entitlement/entitlement_providers.dart';
import 'package:labfox/core/entitlement/paywall.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _FixedEntitlement extends EntitlementController {
  _FixedEntitlement(this.value);
  final Entitlement value;
  @override
  Entitlement build() => value;
}

/// Pumps a button that runs a paid action, and reports whether it ran.
Future<List<String>> _pump(WidgetTester tester, Entitlement entitlement) async {
  final ran = <String>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        entitlementProvider.overrideWith(() => _FixedEntitlement(entitlement)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Consumer(
          builder: (context, ref, _) => Scaffold(
            body: TextButton(
              onPressed: () => runSubscribed(
                context,
                ref,
                feature: PaidFeature.mergeRequestActions,
                action: () async => ran.add('ran'),
              ),
              child: const Text('do it'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return ran;
}

void main() {
  testWidgets('a subscriber runs the action with no interruption', (
    tester,
  ) async {
    final ran = await _pump(tester, Entitlement.subscribed);

    await tester.tap(find.text('do it'));
    await tester.pumpAndSettle();

    expect(ran, ['ran']);
    expect(find.text('Not now'), findsNothing);
  });

  testWidgets('a free user is offered the subscription instead', (
    tester,
  ) async {
    final ran = await _pump(tester, Entitlement.free);

    await tester.tap(find.text('do it'));
    await tester.pumpAndSettle();

    // The action must not run, and the user must be told why and what to do —
    // never a dead button.
    expect(ran, isEmpty);
    expect(find.textContaining('Approving and merging'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
  });
}
