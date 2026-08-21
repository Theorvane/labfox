import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/analytics/analytics.dart';
import 'package:labfox/features/inbox/data/inbox_repository.dart';
import 'package:labfox/features/inbox/presentation/controllers/inbox_controllers.dart';
import 'package:labfox/features/issues/data/issues_repository.dart';
import 'package:labfox/features/issues/presentation/controllers/issues_controllers.dart';

/// Records event names instead of posting anywhere.
class RecordingAnalytics implements Analytics {
  final List<String> events = [];

  @override
  Future<void> track(String name, [Map<String, Object?>? properties]) async {
    events.add(name);
  }
}

class _FakeIssues extends IssuesRepository {
  _FakeIssues()
    : super(GitLabClient(baseUrl: 'https://gitlab.com', token: 'x'));

  @override
  Future<Issue> create({
    required int projectId,
    required String title,
    String? description,
  }) async => const Issue(id: 1, iid: 2, title: 't', state: 'opened');
}

class _FakeInbox extends InboxRepository {
  _FakeInbox() : super(GitLabClient(baseUrl: 'https://gitlab.com', token: 'x'));

  @override
  Future<List<Todo>> list({
    required TodoState state,
    TodoType? type,
    TodoAction? action,
  }) async => const [Todo(id: 9, state: 'pending', actionName: 'assigned')];

  @override
  Future<void> markDone(int id) async {}
}

void main() {
  test('creating an issue tracks issue_created', () async {
    final analytics = RecordingAnalytics();
    final container = ProviderContainer(
      overrides: [
        analyticsProvider.overrideWithValue(analytics),
        issuesRepositoryProvider.overrideWith((ref) async => _FakeIssues()),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(newIssueControllerProvider.notifier)
        .submit(projectId: 7, title: 'crash');

    expect(analytics.events, contains('issue_created'));
  });

  test('clearing a todo tracks todo_cleared', () async {
    final analytics = RecordingAnalytics();
    final container = ProviderContainer(
      overrides: [
        analyticsProvider.overrideWithValue(analytics),
        inboxRepositoryProvider.overrideWith((ref) async => _FakeInbox()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(inboxControllerProvider(const InboxQuery()).future);
    await container
        .read(inboxControllerProvider(const InboxQuery()).notifier)
        .markDone(9);

    expect(analytics.events, contains('todo_cleared'));
  });
}
