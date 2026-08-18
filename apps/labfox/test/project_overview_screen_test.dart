import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/project_overview/data/project_overview.dart';
import 'package:labfox/features/project_overview/presentation/controllers/project_overview_controller.dart';
import 'package:labfox/features/project_overview/presentation/project_overview_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubController extends ProjectOverviewController {
  _StubController(this._value);

  final AsyncValue<ProjectOverview> _value;

  @override
  Future<ProjectOverview> build(int projectId) {
    return _value.when(
      data: (d) => Future.value(d),
      loading: () => Completer<ProjectOverview>().future,
      error: (e, s) => Future.error(e, s),
    );
  }
}

Future<void> _pump(
  WidgetTester tester,
  AsyncValue<ProjectOverview> value,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        projectOverviewControllerProvider.overrideWith(
          () => _StubController(value),
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProjectOverviewScreen(projectId: 1),
      ),
    ),
  );
  await tester.pump();
}

ProjectOverview _overview({String? readme}) => ProjectOverview(
  project: const Project(
    id: 1,
    name: 'backend',
    pathWithNamespace: 'youthpick/backend',
    visibility: 'private',
    starCount: 12,
  ),
  readme: readme,
);

void main() {
  testWidgets('shows a spinner while loading', (tester) async {
    await _pump(tester, const AsyncLoading());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the header and renders the README', (tester) async {
    await _pump(
      tester,
      AsyncData(_overview(readme: '# Backend\n\nThe service.')),
    );
    await tester.pumpAndSettle();

    expect(find.text('youthpick/backend'), findsOneWidget);
    expect(find.text('private'), findsOneWidget);
    expect(find.byType(MarkdownViewer), findsOneWidget);
  });

  testWidgets('shows a no-README message, not a blank, when there is none', (
    tester,
  ) async {
    await _pump(tester, AsyncData(_overview(readme: null)));
    await tester.pumpAndSettle();

    expect(find.byType(MarkdownViewer), findsNothing);
    expect(find.textContaining('no README'), findsOneWidget);
  });

  testWidgets('shows an error with retry on failure', (tester) async {
    await _pump(tester, AsyncError(Exception('boom'), StackTrace.current));
    await tester.pump();

    expect(find.textContaining('Could not load this project'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });
}
