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
  testWidgets('renders a legacy snippet without a files array', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectSnippetProvider.overrideWith(
            (ref, item) async => const Snippet(id: 7, title: 'Legacy snippet'),
          ),
          snippetRawProvider.overrideWith((ref, item) async => 'raw content'),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SnippetDetailScreen(projectId: 42, snippetId: 7),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Legacy snippet'), findsWidgets);
    expect(find.text('Content'), findsOneWidget);
    expect(find.text('raw content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'lists multiple files without requesting single-file raw content',
    (tester) async {
      var rawRequests = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectSnippetProvider.overrideWith(
              (ref, item) async => const Snippet(
                id: 8,
                title: 'Multi-file snippet',
                files: [
                  SnippetFile(path: 'first.dart'),
                  SnippetFile(path: 'second.dart'),
                ],
              ),
            ),
            snippetRawProvider.overrideWith((ref, item) async {
              rawRequests++;
              return 'unexpected';
            }),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SnippetDetailScreen(projectId: 42, snippetId: 8),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('first.dart'), findsOneWidget);
      expect(find.text('second.dart'), findsOneWidget);
      expect(rawRequests, 0);
    },
  );

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
