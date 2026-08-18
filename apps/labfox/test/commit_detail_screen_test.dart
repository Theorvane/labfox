import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/commits/presentation/commit_detail_screen.dart';
import 'package:labfox/features/commits/presentation/controllers/history_controllers.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubCommit extends CommitController {
  _StubCommit(this._value);
  final AsyncValue<Commit> _value;

  @override
  Future<Commit> build(CommitRef arg) {
    return _value.when(
      data: (v) => Future.value(v),
      loading: () => Completer<Commit>().future,
      error: (e, s) => Future.error(e, s),
    );
  }
}

Future<void> _pump(WidgetTester tester, AsyncValue<Commit> value) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        commitControllerProvider.overrideWith(() => _StubCommit(value)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CommitDetailScreen(projectId: 1, sha: 'abc123'),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('shows the message body and change stats', (tester) async {
    await _pump(
      tester,
      const AsyncData(
        Commit(
          id: 'abc123',
          rawShortId: 'abc123',
          title: 'feat: add sign-in',
          message: 'feat: add sign-in\n\nValidate the token first.',
          stats: CommitStats(additions: 10, deletions: 3, total: 13),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('feat: add sign-in'), findsOneWidget);
    expect(find.textContaining('Validate the token first'), findsOneWidget);
    expect(find.text('+10'), findsOneWidget);
    expect(find.text('-3'), findsOneWidget);
  });

  testWidgets('shows only the title when there is no body', (tester) async {
    await _pump(
      tester,
      const AsyncData(
        Commit(
          id: 'abc123',
          rawShortId: 'abc123',
          title: 'chore: bump deps',
          message: 'chore: bump deps',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('chore: bump deps'), findsOneWidget);
  });
}
