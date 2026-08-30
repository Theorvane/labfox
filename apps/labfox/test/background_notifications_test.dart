import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/core/auth/auth_providers.dart';
import 'package:labfox/core/entitlement/entitlement.dart';
import 'package:labfox/core/entitlement/entitlement_providers.dart';
import 'package:labfox/core/notifications/background_notifications.dart';
import 'package:labfox/core/notifications/notifications_providers.dart';
import 'package:labfox/core/settings/app_settings_providers.dart';
import 'package:labfox/core/ui/link_opener.dart';
import 'package:labfox/features/settings/presentation/settings_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FixedEntitlement extends EntitlementController {
  _FixedEntitlement(this.value);
  final Entitlement value;
  @override
  Entitlement build() => value;
}

/// Records the scheduling calls instead of touching a platform channel.
class _RecordingChecks implements BackgroundChecks {
  _RecordingChecks({this.granted = true});

  final bool granted;

  final List<String> calls = [];

  @override
  Future<bool> enable() async {
    calls.add('enable');
    return granted;
  }

  @override
  Future<void> disable() async => calls.add('disable');
}

Future<({_RecordingChecks checks, SharedPreferences prefs})> _pump(
  WidgetTester tester, {
  required Entitlement entitlement,
  bool granted = true,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final checks = _RecordingChecks(granted: granted);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appVersionProvider.overrideWith((ref) async => '1.0.0 (1)'),
        linkOpenerProvider.overrideWithValue((uri) async {}),
        freePlatformProvider.overrideWithValue(false),
        mobilePlatformProvider.overrideWithValue(true),
        entitlementProvider.overrideWith(() => _FixedEntitlement(entitlement)),
        backgroundChecksProvider.overrideWithValue(checks),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (checks: checks, prefs: prefs);
}

void main() {
  testWidgets('a subscriber can turn background checks on', (tester) async {
    final r = await _pump(tester, entitlement: Entitlement.subscribed);

    await tester.tap(find.text('Background to-do checks'));
    await tester.pumpAndSettle();

    expect(r.checks.calls, ['enable']);
    expect(r.prefs.getBool(backgroundNotificationsKey), isTrue);
  });

  testWidgets('a free user is offered the subscription and nothing schedules', (
    tester,
  ) async {
    final r = await _pump(tester, entitlement: Entitlement.free);

    await tester.tap(find.text('Background to-do checks'));
    await tester.pumpAndSettle();

    // Nothing is scheduled on their battery until they subscribe.
    expect(r.checks.calls, isEmpty);
    expect(r.prefs.getBool(backgroundNotificationsKey), isNot(true));
    expect(find.text('Not now'), findsOneWidget);
  });

  testWidgets('refusing the notification permission turns the switch back off', (
    tester,
  ) async {
    final r = await _pump(
      tester,
      entitlement: Entitlement.subscribed,
      granted: false,
    );

    await tester.tap(find.text('Background to-do checks'));
    await tester.pumpAndSettle();

    expect(r.checks.calls, ['enable']);
    expect(r.prefs.getBool(backgroundNotificationsKey), isFalse);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    expect(
      find.text(
        'LabFox cannot show notifications until you allow them in system settings.',
      ),
      findsOneWidget,
    );
  });
}
