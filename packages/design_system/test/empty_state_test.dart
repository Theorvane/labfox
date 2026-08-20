import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the glyph, title and optional message and action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.inbox_outlined,
            title: 'No pipelines yet',
            message: 'Runs will show up here.',
            action: FilledButton(onPressed: () {}, child: const Text('Retry')),
          ),
        ),
      ),
    );

    expect(find.text('No pipelines yet'), findsOneWidget);
    expect(find.text('Runs will show up here.'), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });

  testWidgets('omits the message and action when not given', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(icon: Icons.search, title: 'No results found'),
        ),
      ),
    );

    expect(find.text('No results found'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });
}
