import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/features/settings/presentation/settings_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SettingsScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists the licenses entry', (tester) async {
    await _pump(tester);
    expect(find.text('Open source licenses'), findsOneWidget);
  });

  testWidgets('lists the privacy policy entry', (tester) async {
    await _pump(tester);
    expect(find.text('Privacy policy'), findsOneWidget);
  });

  testWidgets('opens the license page, satisfying the notice obligation', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('Open source licenses'));
    await tester.pumpAndSettle();

    // Flutter's LicensePage lists every pub dependency's license.
    expect(find.byType(LicensePage), findsOneWidget);
  });
}
