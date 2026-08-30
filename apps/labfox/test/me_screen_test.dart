import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/core/entitlement/entitlement.dart';
import 'package:labfox/core/entitlement/entitlement_providers.dart';
import 'package:labfox/features/profile/presentation/me_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _FixedEntitlement extends EntitlementController {
  _FixedEntitlement(this.value);
  final Entitlement value;
  @override
  Entitlement build() => value;
}

Future<void> _pump(
  WidgetTester tester, {
  Entitlement entitlement = Entitlement.free,
  bool freePlatform = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentAccountProvider.overrideWithValue(
          const Account(
            instanceUrl: 'https://gitlab.com',
            user: User(id: 1, username: 'jungwon', name: 'Jungwon'),
          ),
        ),
        entitlementProvider.overrideWith(() => _FixedEntitlement(entitlement)),
        freePlatformProvider.overrideWithValue(freePlatform),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MeScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the signed-in user and the account actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentAccountProvider.overrideWithValue(
            const Account(
              instanceUrl: 'https://gitlab.com',
              user: User(id: 1, username: 'jungwon', name: 'Jungwon'),
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jungwon'), findsOneWidget);
    expect(find.text('@jungwon'), findsOneWidget);
    expect(find.text('gitlab.com'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Switch account'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    // The profile can be shared, like GitHub Mobile's Share profile.
    expect(find.text('Share profile'), findsOneWidget);
  });

  testWidgets('a subscriber sees the subscription and its state on Me', (
    tester,
  ) async {
    await _pump(tester, entitlement: Entitlement.subscribed);

    // Whether you are subscribed has to be answerable without opening a
    // submenu.
    expect(find.text('LabFox subscription'), findsOneWidget);
    expect(find.text('Subscribed'), findsWidgets);
  });

  testWidgets('a free user sees what the subscription unlocks on Me', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('LabFox subscription'), findsOneWidget);
    expect(find.textContaining('Approve and merge'), findsOneWidget);
  });

  testWidgets('a free platform is offered nothing', (tester) async {
    await _pump(
      tester,
      freePlatform: true,
      entitlement: Entitlement.subscribed,
    );

    // Windows and macOS ship with every feature; an entry would sell what the
    // user already has.
    expect(find.text('LabFox subscription'), findsNothing);
  });
}
