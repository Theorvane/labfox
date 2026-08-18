import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/projects/presentation/controllers/projects_controller.dart';
import 'package:labfox/features/projects/presentation/projects_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

/// A controller stub that emits a fixed AsyncValue, so each state can be tested
/// without a client or network.
class _StubController extends ProjectsController {
  _StubController(this._value);

  final AsyncValue<List<Project>> _value;

  @override
  Future<List<Project>> build() async {
    return _value.when(
      data: (items) => items,
      // A future that never completes keeps the notifier in AsyncLoading
      // without scheduling a timer that the test clock would flag as pending.
      loading: () => Completer<List<Project>>().future,
      error: (error, stack) => Future<List<Project>>.error(error, stack),
    );
  }
}

Future<void> _pump(WidgetTester tester, AsyncValue<List<Project>> value) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        projectsControllerProvider.overrideWith(() => _StubController(value)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProjectsScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  const projects = [
    Project(
      id: 1,
      name: 'backend',
      pathWithNamespace: 'youthpick/backend',
      starCount: 12,
    ),
    Project(id: 2, name: 'web', pathWithNamespace: 'youthpick/web'),
  ];

  testWidgets('shows a spinner while loading', (tester) async {
    await _pump(tester, const AsyncLoading());
    // A second frame lets the localization delegate resolve before asserting.
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('lists projects with their namespace', (tester) async {
    await _pump(tester, const AsyncData(projects));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectTile), findsNWidgets(2));
    expect(find.text('backend'), findsOneWidget);
    expect(find.text('youthpick/backend'), findsOneWidget);
  });

  testWidgets('shows an empty message, not an error, for zero projects', (
    tester,
  ) async {
    // Zero projects is a valid state and must read differently from a failure.
    await _pump(tester, const AsyncData(<Project>[]));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectTile), findsNothing);
    expect(find.textContaining('not a member of any projects'), findsOneWidget);
  });

  testWidgets('shows an error with a retry action on failure', (tester) async {
    await _pump(tester, AsyncError(Exception('boom'), StackTrace.current));
    await tester.pump();

    expect(find.textContaining('Could not load'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });
}
