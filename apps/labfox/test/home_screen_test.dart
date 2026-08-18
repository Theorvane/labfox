import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/app/app.dart';

Future<void> _pumpAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const ProviderScope(child: LabFoxApp()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the home screen at a phone width', (tester) async {
    await _pumpAt(tester, const Size(390, 844));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Navigation'), findsNothing);
  });

  testWidgets('shows the second pane at a desktop width', (tester) async {
    await _pumpAt(tester, const Size(1440, 900));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Navigation'), findsOneWidget);
  });

  testWidgets('collapses back to one pane when the window narrows', (
    tester,
  ) async {
    // A desktop window dragged narrow has to become the mobile layout; this is
    // the case Platform.isX would get wrong.
    await _pumpAt(tester, const Size(1440, 900));
    expect(find.text('Navigation'), findsOneWidget);

    tester.view.physicalSize = const Size(500, 900);
    await tester.pumpAndSettle();

    expect(find.text('Navigation'), findsNothing);
  });
}
