import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/merge_requests/data/merge_requests_repository.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/new_merge_request_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _FakeRepo extends MergeRequestsRepository {
  _FakeRepo() : super(GitLabClient(baseUrl: 'https://gitlab.com', token: 'x'));
  Map<String, dynamic>? created;

  @override
  Future<MergeRequest> create({
    required int projectId,
    required String sourceBranch,
    required String targetBranch,
    required String title,
    String? description,
  }) async {
    created = {
      'projectId': projectId,
      'source': sourceBranch,
      'target': targetBranch,
      'title': title,
    };
    return MergeRequest(
      id: 1,
      iid: 9,
      title: title,
      state: 'opened',
      sourceBranch: sourceBranch,
      targetBranch: targetBranch,
    );
  }
}

void main() {
  test('submit creates the merge request via the repository', () async {
    final repo = _FakeRepo();
    final container = ProviderContainer(
      overrides: [
        mergeRequestsRepositoryProvider.overrideWith((ref) async => repo),
      ],
    );
    addTearDown(container.dispose);

    final mr = await container
        .read(newMergeRequestControllerProvider.notifier)
        .submit(
          projectId: 42,
          sourceBranch: 'feat/x',
          targetBranch: 'main',
          title: 'Add x',
        );

    expect(mr.iid, 9);
    expect(repo.created, {
      'projectId': 42,
      'source': 'feat/x',
      'target': 'main',
      'title': 'Add x',
    });
  });

  testWidgets('the form requires branches and a title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: NewMergeRequestScreen(projectId: 1),
        ),
      ),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create merge request'));
    await tester.pump();
    expect(find.text('Enter a branch.'), findsNWidgets(2));
    expect(find.text('Enter a title.'), findsOneWidget);
  });
}
