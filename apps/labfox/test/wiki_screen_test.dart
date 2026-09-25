import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/app/router.dart';
import 'package:labfox/features/wiki/presentation/controllers/wiki_controllers.dart';
import 'package:labfox/features/wiki/presentation/wiki_page_screen.dart';
import 'package:labfox/features/wiki/presentation/wiki_pages_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubPages extends WikiPagesController {
  _StubPages(this.value);

  final AsyncValue<List<WikiPage>> value;

  @override
  Future<List<WikiPage>> build(int projectId) => value.when(
    data: Future.value,
    loading: () => Completer<List<WikiPage>>().future,
    error: Future.error,
  );
}

class _StubPage extends WikiPageController {
  _StubPage(this.value);

  final AsyncValue<WikiPage> value;

  @override
  Future<WikiPage> build(WikiPageRef arg) => value.when(
    data: Future.value,
    loading: () => Completer<WikiPage>().future,
    error: Future.error,
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required AsyncValue<List<WikiPage>> pages,
  required AsyncValue<WikiPage> page,
  String initialLocation = '/projects/1/wikis',
  Size? size,
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/projects/:id/wikis',
        builder: (_, state) =>
            WikiPagesScreen(projectId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/projects/:id/wikis/page',
        builder: (_, state) => WikiPageScreen(
          projectId: int.parse(state.pathParameters['id']!),
          slug: state.uri.queryParameters['slug']!,
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        wikiPagesControllerProvider.overrideWith(() => _StubPages(pages)),
        wikiPageControllerProvider.overrideWith(() => _StubPage(page)),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();
}

const _pages = <WikiPage>[
  WikiPage(title: 'Home', slug: 'home'),
  WikiPage(title: 'Install', slug: 'docs/install'),
];
const _page = WikiPage(
  title: 'Install',
  slug: 'docs/install',
  content: '# Install\n\nRun the setup.',
  format: 'markdown',
);

void main() {
  testWidgets('lists wiki pages and opens a nested page inside the app', (
    tester,
  ) async {
    await _pump(
      tester,
      pages: const AsyncData(_pages),
      page: const AsyncData(_page),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Install'), findsOneWidget);
    await tester.tap(find.text('Install'));
    await tester.pumpAndSettle();

    expect(find.byType(MarkdownViewer), findsOneWidget);
    expect(
      tester.widget<WikiPageScreen>(find.byType(WikiPageScreen)).slug,
      'docs/install',
    );
  });

  testWidgets('shows an empty wiki message', (tester) async {
    await _pump(
      tester,
      pages: const AsyncData(<WikiPage>[]),
      page: const AsyncData(_page),
    );
    await tester.pumpAndSettle();

    expect(find.text('No wiki pages yet.'), findsOneWidget);
  });

  testWidgets('shows a retry action on list errors', (tester) async {
    await _pump(
      tester,
      pages: AsyncError(Exception('failed'), StackTrace.current),
      page: const AsyncData(_page),
    );
    await tester.pump();

    expect(find.text('Could not load wiki pages.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });

  testWidgets('shows the page list beside content on wide screens', (
    tester,
  ) async {
    await _pump(
      tester,
      pages: const AsyncData(_pages),
      page: const AsyncData(_page),
      initialLocation: Routes.wikiPage(1, 'docs/install'),
      size: const Size(1200, 800),
    );
    await tester.pumpAndSettle();

    final sidebar = tester.getTopLeft(find.text('Home'));
    final content = tester.getTopLeft(find.byType(MarkdownViewer));
    expect(content.dx, greaterThan(sidebar.dx + 200));
  });

  testWidgets('opens a relative wiki link inside the app', (tester) async {
    await _pump(
      tester,
      pages: const AsyncData(_pages),
      page: const AsyncData(
        WikiPage(
          title: 'Install',
          slug: 'docs/install',
          content: '[Overview](../home)',
          format: 'markdown',
        ),
      ),
      initialLocation: Routes.wikiPage(1, 'docs/install'),
      size: const Size(390, 800),
    );
    await tester.pumpAndSettle();

    final richText = tester.widget<RichText>(
      find
          .descendant(
            of: find.byType(MarkdownViewer),
            matching: find.byType(RichText),
          )
          .first,
    );
    TapGestureRecognizer? link;
    (richText.text as TextSpan).visitChildren((span) {
      if (span is TextSpan && span.recognizer is TapGestureRecognizer) {
        link = span.recognizer! as TapGestureRecognizer;
        return false;
      }
      return true;
    });
    expect(link, isNotNull);
    link!.onTap!();
    await tester.pumpAndSettle();

    expect(
      tester.widget<WikiPageScreen>(find.byType(WikiPageScreen)).slug,
      'home',
    );
  });
}
