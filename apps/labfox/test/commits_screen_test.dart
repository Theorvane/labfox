import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/commits/presentation/commits_screen.dart';
import 'package:labfox/features/commits/presentation/controllers/history_controllers.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubCommits extends CommitsController {
  _StubCommits(this._value);
  final AsyncValue<List<Commit>> _value;

  @override
  Future<List<Commit>> build(CommitsRef arg) {
    return _value.when(
      data: (v) => Future.value(v),
      loading: () => Completer<List<Commit>>().future,
      error: (e, s) => Future.error(e, s),
    );
  }
}

Future<void> _pump(WidgetTester tester, AsyncValue<List<Commit>> value) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        commitsControllerProvider.overrideWith(() => _StubCommits(value)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CommitsScreen(projectId: 1, ref: 'main'),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('lists commits with their short id', (tester) async {
    await _pump(
      tester,
      const AsyncData([
        Commit(
          id: 'abc123def',
          rawShortId: 'abc123de',
          title: 'feat: add sign-in',
          authorName: 'Jungwon',
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('feat: add sign-in'), findsOneWidget);
    expect(find.textContaining('abc123de'), findsOneWidget);
  });

  testWidgets('shows an empty message for a branch with no commits', (
    tester,
  ) async {
    await _pump(tester, const AsyncData(<Commit>[]));
    await tester.pumpAndSettle();
    expect(find.textContaining('No commits'), findsOneWidget);
  });
}
