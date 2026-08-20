import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/core/auth/auth_providers.dart';
import 'package:labfox/core/storage/local_projects_providers.dart';
import 'package:labfox/features/home/presentation/home_screen.dart';
import 'package:labfox/features/project_overview/data/project_overview.dart';
import 'package:labfox/features/project_overview/presentation/controllers/project_overview_controller.dart';
import 'package:labfox/features/project_overview/presentation/project_overview_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Account _account() => const Account(
  instanceUrl: 'https://gitlab.com',
  user: User(id: 1, username: 'u', name: 'U'),
);

Project _project(int id, String name) =>
    Project(id: id, name: name, pathWithNamespace: 'g/$name');

Future<ProviderContainer> _container() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      currentAccountProvider.overrideWithValue(_account()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

class _FixedFavorites extends FavoriteProjectsController {
  _FixedFavorites(this.items);
  final List<Project> items;
  @override
  List<Project> build() => items;
}

class _FixedRecents extends RecentProjectsController {
  _FixedRecents(this.items);
  final List<Project> items;
  @override
  List<Project> build() => items;
}

class _StubOverview extends ProjectOverviewController {
  @override
  Future<ProjectOverview> build(int projectId) async =>
      ProjectOverview(project: _project(projectId, 'backend'));
}

void main() {
  group('RecentProjectsController', () {
    test('records an opened project, newest first', () async {
      final container = await _container();

      expect(container.read(recentProjectsProvider), isEmpty);

      await container
          .read(recentProjectsProvider.notifier)
          .record(_project(1, 'a'));
      await container
          .read(recentProjectsProvider.notifier)
          .record(_project(2, 'b'));

      expect(container.read(recentProjectsProvider).map((p) => p.id), [2, 1]);
    });

    test('records nothing when signed out', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          currentAccountProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(recentProjectsProvider.notifier)
          .record(_project(1, 'a'));

      expect(container.read(recentProjectsProvider), isEmpty);
    });
  });

  group('FavoriteProjectsController', () {
    test('toggles a project on and off', () async {
      final container = await _container();
      final notifier = container.read(favoriteProjectsProvider.notifier);

      await notifier.toggle(_project(1, 'a'));
      expect(container.read(favoriteProjectsProvider).map((p) => p.id), [1]);
      expect(notifier.isFavorite(1), isTrue);

      await notifier.toggle(_project(1, 'a'));
      expect(container.read(favoriteProjectsProvider), isEmpty);
    });
  });

  group('HomeScreen sections', () {
    Future<void> pump(
      WidgetTester tester, {
      required List<Project> favorites,
      required List<Project> recents,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentAccountProvider.overrideWithValue(_account()),
            favoriteProjectsProvider.overrideWith(
              () => _FixedFavorites(favorites),
            ),
            recentProjectsProvider.overrideWith(() => _FixedRecents(recents)),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows favorites and recents when present', (tester) async {
      await pump(
        tester,
        favorites: [_project(1, 'fav')],
        recents: [_project(2, 'rec')],
      );

      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('fav'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);
      expect(find.text('rec'), findsOneWidget);
    });

    testWidgets('hides the sections when empty', (tester) async {
      await pump(tester, favorites: const [], recents: const []);

      expect(find.text('Favorites'), findsNothing);
      expect(find.text('Recent'), findsNothing);
    });
  });

  group('ProjectOverviewScreen favorite toggle', () {
    testWidgets('the star toggles the favorite', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            currentAccountProvider.overrideWithValue(_account()),
            projectOverviewControllerProvider.overrideWith(_StubOverview.new),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ProjectOverviewScreen(projectId: 5),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.widgetWithIcon(IconButton, Icons.star_border),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithIcon(IconButton, Icons.star_border));
      await tester.pumpAndSettle();

      expect(find.widgetWithIcon(IconButton, Icons.star), findsOneWidget);
    });

    testWidgets('opening the project records it as recent', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          currentAccountProvider.overrideWithValue(_account()),
          projectOverviewControllerProvider.overrideWith(_StubOverview.new),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ProjectOverviewScreen(projectId: 5),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(recentProjectsProvider).map((p) => p.id), [5]);
    });
  });
}
