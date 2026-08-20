import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/core/ui/copy_link_button.dart';
import 'package:labfox/l10n/app_localizations.dart';

Future<void> _pump(WidgetTester tester, String? url) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        appBar: AppBar(actions: [CopyLinkButton(url: url)]),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('copies the url and confirms with a snackbar', (tester) async {
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );

    await _pump(tester, 'https://gitlab.com/acme/app/-/merge_requests/1');
    await tester.tap(find.byIcon(Icons.ios_share));
    await tester.pumpAndSettle();

    expect(copied.single, 'https://gitlab.com/acme/app/-/merge_requests/1');
    expect(find.text('Link copied'), findsOneWidget);
  });

  testWidgets('renders nothing without a url', (tester) async {
    await _pump(tester, null);
    expect(find.byIcon(Icons.ios_share), findsNothing);
  });
}
