import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/issues/presentation/controllers/issues_controllers.dart';
import 'package:labfox/features/issues/presentation/issue_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubIssue extends IssueController {
  _StubIssue(this._value);
  final AsyncValue<Issue> _value;

  @override
  Future<Issue> build(IssueRef arg) {
    return _value.when(
      data: (v) => Future.value(v),
      loading: () => Completer<Issue>().future,
      error: (e, s) => Future.error(e, s),
    );
  }
}

Future<void> _pump(WidgetTester tester, AsyncValue<Issue> value) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        issueControllerProvider.overrideWith(() => _StubIssue(value)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: IssueDetailScreen(projectId: 1, iid: 282),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('renders title, iid, state, labels, and description', (
    tester,
  ) async {
    await _pump(
      tester,
      const AsyncData(
        Issue(
          id: 99401,
          iid: 282,
          title: 'Android login error',
          state: 'opened',
          description: 'The OAuth redirect fails.',
          author: User(id: 7, username: 'jungwon', name: 'Jungwon'),
          labels: ['bug', 'android'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Android login error'), findsOneWidget);
    expect(find.text('#282'), findsOneWidget);
    expect(find.byType(IssueStateBadge), findsOneWidget);
    expect(find.byType(GitLabLabel), findsNWidgets(2));
    expect(find.byType(MarkdownViewer), findsOneWidget);
  });

  testWidgets('shows a no-description message when empty', (tester) async {
    await _pump(
      tester,
      const AsyncData(Issue(id: 1, iid: 5, title: 'x', state: 'closed')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MarkdownViewer), findsNothing);
    expect(find.textContaining('No description'), findsOneWidget);
  });
}
