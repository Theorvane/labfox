import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/issues/presentation/controllers/issues_controllers.dart';
import 'package:labfox/features/issues/presentation/issues_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubIssues extends IssuesController {
  _StubIssues(this._byState);
  final Map<IssueState, AsyncValue<List<Issue>>> _byState;

  @override
  Future<List<Issue>> build(IssuesQuery arg) {
    final value = _byState[arg.state] ?? const AsyncData(<Issue>[]);
    return value.when(
      data: (v) => Future.value(v),
      loading: () => Completer<List<Issue>>().future,
      error: (e, s) => Future.error(e, s),
    );
  }
}

Future<void> _pump(
  WidgetTester tester,
  Map<IssueState, AsyncValue<List<Issue>>> byState,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        issuesControllerProvider.overrideWith(() => _StubIssues(byState)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: IssuesScreen(projectId: 1),
      ),
    ),
  );
  await tester.pump();
}

Issue _issue(int iid, String title, {String state = 'opened'}) =>
    Issue(id: iid * 100, iid: iid, title: title, state: state);

void main() {
  testWidgets('lists open issues with their iid', (tester) async {
    await _pump(tester, {
      IssueState.opened: AsyncData([_issue(282, 'Android login error')]),
    });
    await tester.pumpAndSettle();

    expect(find.text('Android login error'), findsOneWidget);
    expect(find.text('#282'), findsOneWidget);
  });

  testWidgets('shows an assignee avatar when the issue is assigned', (
    tester,
  ) async {
    await _pump(tester, {
      IssueState.opened: const AsyncData([
        Issue(
          id: 1,
          iid: 5,
          title: 'assigned',
          state: 'opened',
          assignees: [User(id: 2, username: 'ari', name: 'Ari')],
        ),
      ]),
    });
    await tester.pumpAndSettle();

    expect(find.byType(UserAvatar), findsOneWidget);
  });

  testWidgets('shows a relative updated time on the row', (tester) async {
    await _pump(tester, {
      IssueState.opened: AsyncData([
        Issue(
          id: 1,
          iid: 5,
          title: 'recent',
          state: 'opened',
          updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ]),
    });
    await tester.pumpAndSettle();

    expect(find.text('3h'), findsOneWidget);
  });

  testWidgets('switching the filter to Closed loads closed issues', (
    tester,
  ) async {
    await _pump(tester, {
      IssueState.opened: AsyncData([_issue(1, 'open one')]),
      IssueState.closed: AsyncData([_issue(2, 'closed one', state: 'closed')]),
    });
    await tester.pumpAndSettle();
    expect(find.text('open one'), findsOneWidget);

    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();

    expect(find.text('closed one'), findsOneWidget);
    expect(find.text('open one'), findsNothing);
  });

  testWidgets('shows an empty message when there are no issues', (
    tester,
  ) async {
    await _pump(tester, {IssueState.opened: const AsyncData(<Issue>[])});
    await tester.pumpAndSettle();
    expect(find.textContaining('No issues'), findsOneWidget);
  });
}
