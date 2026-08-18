import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/branches/presentation/branches_screen.dart';
import 'package:labfox/features/commits/presentation/controllers/history_controllers.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubBranches extends BranchesController {
  _StubBranches(this._value);
  final AsyncValue<List<Branch>> _value;

  @override
  Future<List<Branch>> build(int projectId) {
    return _value.when(
      data: (v) => Future.value(v),
      loading: () => Completer<List<Branch>>().future,
      error: (e, s) => Future.error(e, s),
    );
  }
}

Future<void> _pump(WidgetTester tester, AsyncValue<List<Branch>> value) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        branchesControllerProvider.overrideWith(() => _StubBranches(value)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BranchesScreen(projectId: 1),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('lists branches and marks the default', (tester) async {
    await _pump(
      tester,
      const AsyncData([
        Branch(name: 'main', isDefault: true, isProtected: true),
        Branch(name: 'dev'),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('main'), findsOneWidget);
    expect(find.text('dev'), findsOneWidget);
    expect(find.textContaining('Default branch'), findsOneWidget);
  });

  testWidgets('shows an empty message when there are no branches', (
    tester,
  ) async {
    await _pump(tester, const AsyncData(<Branch>[]));
    await tester.pumpAndSettle();
    expect(find.textContaining('no branches'), findsOneWidget);
  });

  testWidgets('shows an error with retry', (tester) async {
    await _pump(tester, AsyncError(Exception('x'), StackTrace.current));
    await tester.pump();
    expect(find.textContaining('Could not load branches'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });
}
