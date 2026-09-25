import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/snippets/presentation/controllers/snippets_controller.dart';
import 'package:labfox/features/snippets/presentation/snippets_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

Future<void> pumpSnippets(WidgetTester tester, List<Snippet> snippets) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        projectSnippetsProvider.overrideWith((ref, id) async => snippets),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SnippetsScreen(projectId: 42),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists project snippets with title and description', (
    tester,
  ) async {
    await pumpSnippets(tester, const [
      Snippet(id: 7, title: 'Deploy script', description: 'Release helper'),
    ]);

    expect(find.text('Deploy script'), findsOneWidget);
    expect(find.text('Release helper'), findsOneWidget);
  });

  testWidgets('shows an empty state when the project has no snippets', (
    tester,
  ) async {
    await pumpSnippets(tester, const []);
    expect(find.text('No snippets yet'), findsOneWidget);
  });
}
