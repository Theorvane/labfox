import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/issues_repository.dart';

final issuesRepositoryProvider = FutureProvider<IssuesRepository?>((ref) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : IssuesRepository(client);
});

/// Identifies an issue list: which project, which state filter.
class IssuesQuery {
  const IssuesQuery({required this.projectId, this.state = IssueState.opened});

  final int projectId;
  final IssueState state;

  @override
  bool operator ==(Object other) =>
      other is IssuesQuery &&
      other.projectId == projectId &&
      other.state == state;

  @override
  int get hashCode => Object.hash(projectId, state);
}

/// Lists issues for a query.
class IssuesController extends FamilyAsyncNotifier<List<Issue>, IssuesQuery> {
  @override
  Future<List<Issue>> build(IssuesQuery arg) async {
    final repo = await ref.watch(issuesRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.list(projectId: arg.projectId, state: arg.state);
  }
}

final issuesControllerProvider =
    AsyncNotifierProvider.family<IssuesController, List<Issue>, IssuesQuery>(
      IssuesController.new,
    );

/// Identifies one issue by its per-project iid.
class IssueRef {
  const IssueRef({required this.projectId, required this.iid});

  final int projectId;
  final int iid;

  @override
  bool operator ==(Object other) =>
      other is IssueRef && other.projectId == projectId && other.iid == iid;

  @override
  int get hashCode => Object.hash(projectId, iid);
}

/// Loads one issue's detail.
class IssueController extends FamilyAsyncNotifier<Issue, IssueRef> {
  @override
  Future<Issue> build(IssueRef arg) async {
    final repo = await ref.watch(issuesRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.get(projectId: arg.projectId, iid: arg.iid);
  }
}

final issueControllerProvider =
    AsyncNotifierProvider.family<IssueController, Issue, IssueRef>(
      IssueController.new,
    );
