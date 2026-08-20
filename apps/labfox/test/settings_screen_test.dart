import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/core/ui/link_opener.dart';
import 'package:labfox/features/settings/presentation/settings_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

Future<List<Uri>> _pump(WidgetTester tester) async {
  final opened = <Uri>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        linkOpenerProvider.overrideWithValue((uri) async => opened.add(uri)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return opened;
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

  testWidgets('terms of service opens the company terms page', (tester) async {
    final opened = await _pump(tester);

    await tester.tap(find.text('Terms of service'));
    await tester.pumpAndSettle();

    expect(opened, [Uri.parse('https://www.sloki9637.com/terms')]);
  });
}
