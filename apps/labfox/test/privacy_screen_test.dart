import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/features/settings/presentation/privacy_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

void main() {
  testWidgets('renders the bundled privacy policy', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PrivacyScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The bundled PRIVACY.md renders through the markdown viewer.
    expect(find.byType(MarkdownViewer), findsOneWidget);
    expect(find.textContaining('sloki9637', findRichText: true), findsWidgets);
  });
}
