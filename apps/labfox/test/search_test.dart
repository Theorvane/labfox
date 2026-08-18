import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/search/data/search_repository.dart';
import 'package:labfox/features/search/presentation/controllers/search_controllers.dart';
import 'package:labfox/features/search/presentation/search_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

Project _project(int id, String name) =>
    Project(id: id, name: name, pathWithNamespace: 'g/$name');

class _FakeRepo extends SearchRepository {
  _FakeRepo()
    : super(GitLabClient(baseUrl: 'https://gitlab.com', token: 'glpat-x'));

  final List<int> pagesRequested = [];
  bool failNextPage = false;

  @override
  Future<SearchResults> search(
    SearchScope scope,
    String query, {
    int page = 1,
  }) async {
    pagesRequested.add(page);
    if (page == 1) {
      return SearchResults(items: [_project(7, 'labfox')], nextPage: 2);
    }
    if (failNextPage) {
      throw const GitLabServerException('boom', statusCode: 500);
    }
    return SearchResults(items: [_project(8, 'labcoat')]);
  }
}

Future<void> _pump(WidgetTester tester, _FakeRepo repo) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [searchRepositoryProvider.overrideWith((ref) async => repo)],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SearchScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('SearchController', () {
    test('a blank term searches for nothing', () async {
      final repo = _FakeRepo();
      final container = ProviderContainer(
        overrides: [searchRepositoryProvider.overrideWith((ref) async => repo)],
      );
      addTearDown(container.dispose);

      final results = await container.read(
        searchControllerProvider(
          const SearchQuery(scope: SearchScope.projects, text: '  '),
        ).future,
      );

      expect(results.items, isEmpty);
      expect(repo.pagesRequested, isEmpty);
    });

    test('loadMore appends the next page and advances the cursor', () async {
      final repo = _FakeRepo();
      final container = ProviderContainer(
        overrides: [searchRepositoryProvider.overrideWith((ref) async => repo)],
      );
      addTearDown(container.dispose);

      const query = SearchQuery(scope: SearchScope.projects, text: 'lab');
      final first = await container.read(
        searchControllerProvider(query).future,
      );
      expect(first.items.length, 1);
      expect(first.hasMore, isTrue);

      await container.read(searchControllerProvider(query).notifier).loadMore();

      final all = container.read(searchControllerProvider(query)).value!;
      expect(all.items.length, 2);
      expect(all.hasMore, isFalse);
      expect(repo.pagesRequested, [1, 2]);
    });

    test(
      'a failed loadMore keeps the page and flags a recoverable error',
      () async {
        final repo = _FakeRepo()..failNextPage = true;
        final container = ProviderContainer(
          overrides: [
            searchRepositoryProvider.overrideWith((ref) async => repo),
          ],
        );
        addTearDown(container.dispose);

        const query = SearchQuery(scope: SearchScope.projects, text: 'lab');
        await container.read(searchControllerProvider(query).future);

        // Must not throw out of loadMore — an escaping error becomes an
        // unhandled async error and leaves the button falsely enabled.
        await container
            .read(searchControllerProvider(query).notifier)
            .loadMore();

        final result = container.read(searchControllerProvider(query)).value!;
        expect(result.items.length, 1, reason: 'first page is preserved');
        expect(result.loadingMore, isFalse);
        expect(result.loadMoreFailed, isTrue);
        expect(result.hasMore, isTrue, reason: 'the page can be retried');
      },
    );
  });

  group('SearchScreen', () {
    testWidgets('shows an initial hint before a term is entered', (
      tester,
    ) async {
      await _pump(tester, _FakeRepo());
      expect(find.text('Type to search.'), findsOneWidget);
    });

    testWidgets('searching after a debounce shows results', (tester) async {
      await _pump(tester, _FakeRepo());

      await tester.enterText(find.byType(TextField), 'lab');
      // Let the 350ms debounce elapse, then the request resolve.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('labfox'), findsOneWidget);
    });

    testWidgets('Load more appends the next page', (tester) async {
      await _pump(tester, _FakeRepo());

      await tester.enterText(find.byType(TextField), 'lab');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Load more'));
      await tester.pumpAndSettle();

      expect(find.text('labfox'), findsOneWidget);
      expect(find.text('labcoat'), findsOneWidget);
    });

    testWidgets('a failed Load more shows a retry, not a silent failure', (
      tester,
    ) async {
      final repo = _FakeRepo()..failNextPage = true;
      await _pump(tester, repo);

      await tester.enterText(find.byType(TextField), 'lab');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Load more'));
      await tester.pumpAndSettle();

      // The first page stays, and the failure is surfaced with a retry.
      expect(find.text('labfox'), findsOneWidget);
      expect(find.text('The search could not be completed.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
