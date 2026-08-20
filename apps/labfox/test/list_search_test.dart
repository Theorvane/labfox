import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/issues/data/issues_repository.dart';
import 'package:labfox/features/issues/presentation/controllers/issues_controllers.dart';
import 'package:labfox/features/issues/presentation/issues_screen.dart';
import 'package:labfox/features/merge_requests/data/merge_requests_repository.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/merge_requests_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _FakeIssues extends IssuesRepository {
  _FakeIssues()
    : super(GitLabClient(baseUrl: 'https://gitlab.com', token: 'x'));
  final calls = <String>[];

  @override
  Future<List<Issue>> list({
    required int projectId,
    required IssueState state,
    String? search,
  }) async {
    calls.add('${state.value}/${search ?? '-'}');
    return const [
      Issue(id: 1, iid: 5, title: 'crash on start', state: 'opened'),
    ];
  }
}

class _FakeMrs extends MergeRequestsRepository {
  _FakeMrs() : super(GitLabClient(baseUrl: 'https://gitlab.com', token: 'x'));
  final calls = <String>[];

  @override
  Future<List<MergeRequest>> list({
    required int projectId,
    required MergeRequestState state,
    String? search,
  }) async {
    calls.add('${state.value}/${search ?? '-'}');
    return const [];
  }
}

Future<void> _pump(WidgetTester tester, List<Override> overrides, Widget home) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
}

void main() {
  testWidgets('searching the issue list queries the search term', (
    tester,
  ) async {
    final repo = _FakeIssues();
    await _pump(tester, [
      issuesRepositoryProvider.overrideWith((ref) async => repo),
    ], const IssuesScreen(projectId: 1));
    await tester.pumpAndSettle();
    expect(repo.calls, ['opened/-']);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'crash');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(repo.calls, ['opened/-', 'opened/crash']);
  });

  testWidgets('closing issue search restores the unfiltered list', (
    tester,
  ) async {
    final repo = _FakeIssues();
    await _pump(tester, [
      issuesRepositoryProvider.overrideWith((ref) async => repo),
    ], const IssuesScreen(projectId: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'crash');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Back to the unfiltered query — served from the family's cache, so no
    // extra network call — and the field is gone.
    expect(repo.calls, ['opened/-', 'opened/crash']);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('crash on start'), findsOneWidget);
  });

  testWidgets('searching the merge request list queries the search term', (
    tester,
  ) async {
    final repo = _FakeMrs();
    await _pump(tester, [
      mergeRequestsRepositoryProvider.overrideWith((ref) async => repo),
    ], const MergeRequestsScreen(projectId: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'viewer');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(repo.calls, ['opened/-', 'opened/viewer']);
  });
}
