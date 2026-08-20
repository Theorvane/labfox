import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/commits/data/history_repository.dart';
import 'package:labfox/features/commits/presentation/controllers/history_controllers.dart';

class _FakeRepo extends HistoryRepository {
  _FakeRepo() : super(GitLabClient(baseUrl: 'https://gitlab.com', token: 'x'));
  final created = <String>[];
  List<Branch> _branches = const [Branch(name: 'main', isDefault: true)];

  @override
  Future<List<Branch>> branches(int projectId) async => _branches;

  @override
  Future<Branch> createBranch({
    required int projectId,
    required String name,
    required String ref,
  }) async {
    created.add('$name<-$ref');
    _branches = [..._branches, Branch(name: name)];
    return Branch(name: name);
  }
}

void main() {
  test('create posts the branch and reloads the list', () async {
    final repo = _FakeRepo();
    final container = ProviderContainer(
      overrides: [historyRepositoryProvider.overrideWith((ref) async => repo)],
    );
    addTearDown(container.dispose);
    await container.read(branchesControllerProvider(7).future);

    await container
        .read(branchesControllerProvider(7).notifier)
        .create(name: 'feat/x', ref: 'main');

    expect(repo.created, ['feat/x<-main']);
    final names = container
        .read(branchesControllerProvider(7))
        .value!
        .map((b) => b.name);
    expect(names, contains('feat/x'));
  });
}
