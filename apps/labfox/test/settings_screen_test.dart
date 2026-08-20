import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/core/auth/auth_providers.dart';
import 'package:labfox/core/settings/app_settings_providers.dart';
import 'package:labfox/features/settings/presentation/settings_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appVersionProvider.overrideWith((ref) async => '1.2.3 (45)'),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('lists the licenses entry', (tester) async {
    await _pump(tester);
    expect(find.text('Open source licenses'), findsOneWidget);
  });

  testWidgets('opens the license page, satisfying the notice obligation', (
    tester,
  ) async {
    await _pump(tester);

    await tester.scrollUntilVisible(find.text('Open source licenses'), 100);
    await tester.tap(find.text('Open source licenses'));
    await tester.pumpAndSettle();

    // Flutter's LicensePage lists every pub dependency's license.
    expect(find.byType(LicensePage), findsOneWidget);
  });

  testWidgets('the theme choice persists and applies app-wide', (tester) async {
    final container = await _pump(tester);

    // System is the default until the user chooses.
    expect(container.read(themeModeProvider), ThemeMode.system);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'dark');
  });

  testWidgets('shows the app version', (tester) async {
    await _pump(tester);
    expect(find.textContaining('1.2.3'), findsOneWidget);
  });
}
