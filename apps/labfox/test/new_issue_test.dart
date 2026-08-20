import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/issues/data/issues_repository.dart';
import 'package:labfox/features/issues/presentation/controllers/issues_controllers.dart';
import 'package:labfox/features/issues/presentation/new_issue_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _FakeRepo extends IssuesRepository {
  _FakeRepo() : super(GitLabClient(baseUrl: 'https://gitlab.com', token: 'x'));
  Map<String, dynamic>? created;

  @override
  Future<Issue> create({
    required int projectId,
    required String title,
    String? description,
  }) async {
    created = {'projectId': projectId, 'title': title, 'desc': description};
    return Issue(id: 1, iid: 5, title: title, state: 'opened');
  }
}

void main() {
  test('submit creates the issue via the repository', () async {
    final repo = _FakeRepo();
    final container = ProviderContainer(
      overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
    );
    addTearDown(container.dispose);

    final issue = await container
        .read(newIssueControllerProvider.notifier)
        .submit(projectId: 42, title: 'Bug', description: 'broke');

    expect(issue.iid, 5);
    expect(repo.created, {'projectId': 42, 'title': 'Bug', 'desc': 'broke'});
  });

  testWidgets('the form requires a title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: NewIssueScreen(projectId: 1),
        ),
      ),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create issue'));
    await tester.pump();
    expect(find.text('Enter a title.'), findsOneWidget);
  });
}
