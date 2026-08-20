import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/features/issues/data/issues_repository.dart';
import 'package:labfox/features/issues/presentation/controllers/issues_controllers.dart';
import 'package:labfox/features/merge_requests/data/merge_requests_repository.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';

class _FakeIssues extends IssuesRepository {
  _FakeIssues()
    : super(GitLabClient(baseUrl: 'https://gitlab.com', token: 'x'));
  final calls = <String>[];

  @override
  Future<List<Issue>> listMine({
    required IssueScope scope,
    required IssueState state,
  }) async {
    calls.add('${scope.value}/${state.value}');
    return const [Issue(id: 1, iid: 5, title: 'mine', state: 'opened')];
  }
}

class _FakeMrs extends MergeRequestsRepository {
  _FakeMrs() : super(GitLabClient(baseUrl: 'https://gitlab.com', token: 'x'));
  final calls = <String>[];

  @override
  Future<List<MergeRequest>> listMine({
    required MergeRequestScope scope,
    required MergeRequestState state,
  }) async {
    calls.add('mine:${scope.value}');
    return const [];
  }

  @override
  Future<List<MergeRequest>> listForReview(
    String username, {
    required MergeRequestState state,
  }) async {
    calls.add('review:$username');
    return const [];
  }
}

void main() {
  test('my issues pass the scope and state through', () async {
    final repo = _FakeIssues();
    final container = ProviderContainer(
      overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
    );
    addTearDown(container.dispose);

    final items = await container.read(
      myIssuesControllerProvider(
        const MyIssuesQuery(
          scope: IssueScope.createdByMe,
          state: IssueState.closed,
        ),
      ).future,
    );

    expect(items.single.title, 'mine');
    expect(repo.calls, ['created_by_me/closed']);
  });

  test('review requests filter by the signed-in username', () async {
    final repo = _FakeMrs();
    final container = ProviderContainer(
      overrides: [
        mergeRequestsRepositoryProvider.overrideWith((ref) async => repo),
        currentAccountProvider.overrideWithValue(
          const Account(
            instanceUrl: 'https://gitlab.com',
            user: User(id: 1, username: 'jungwon', name: 'Jungwon'),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(
      myMergeRequestsControllerProvider(
        const MyMergeRequestsQuery(
          scope: MyMergeRequestScope.reviewRequests,
          state: MergeRequestState.opened,
        ),
      ).future,
    );

    expect(repo.calls, ['review:jungwon']);
  });
}
