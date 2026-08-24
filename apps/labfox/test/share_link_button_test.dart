import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/core/ui/share_link_button.dart';
import 'package:labfox/l10n/app_localizations.dart';

Future<void> _pump(WidgetTester tester, String? url) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        appBar: AppBar(actions: [ShareLinkButton(url: url)]),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('opens the system share sheet with the url', (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/share'),
      (call) async {
        calls.add(call);
        return 'dev.fluttercommunity.plus/share.success';
      },
    );

    await _pump(tester, 'https://gitlab.com/acme/app/-/merge_requests/1');
    await tester.tap(find.byIcon(Icons.ios_share));
    await tester.pumpAndSettle();

    expect(calls.single.method, 'share');
  });

  testWidgets('renders nothing without a url', (tester) async {
    await _pump(tester, null);
    expect(find.byIcon(Icons.ios_share), findsNothing);
  });
}
