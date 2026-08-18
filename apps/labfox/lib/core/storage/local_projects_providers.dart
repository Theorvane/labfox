import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_providers.dart';
import 'local_projects_store.dart';

final localProjectsStoreProvider = Provider<LocalProjectsStore>((ref) {
  return LocalProjectsStore(ref.watch(sharedPreferencesProvider));
});

/// The active account's recently opened projects, newest first.
class RecentProjectsController extends Notifier<List<Project>> {
  @override
  List<Project> build() {
    final account = ref.watch(currentAccountProvider);
    if (account == null) {
      return const [];
    }
    return ref.watch(localProjectsStoreProvider).readRecents(account.id);
  }

  Future<void> record(Project project) async {
    final account = ref.read(currentAccountProvider);
    if (account == null) {
      return;
    }
    final store = ref.read(localProjectsStoreProvider);
    await store.recordRecent(account.id, project);
    state = store.readRecents(account.id);
  }
}

final recentProjectsProvider =
    NotifierProvider<RecentProjectsController, List<Project>>(
      RecentProjectsController.new,
    );

/// The active account's favorited projects.
class FavoriteProjectsController extends Notifier<List<Project>> {
  @override
  List<Project> build() {
    final account = ref.watch(currentAccountProvider);
    if (account == null) {
      return const [];
    }
    return ref.watch(localProjectsStoreProvider).readFavorites(account.id);
  }

  bool isFavorite(int projectId) => state.any((p) => p.id == projectId);

  Future<void> toggle(Project project) async {
    final account = ref.read(currentAccountProvider);
    if (account == null) {
      return;
    }
    final store = ref.read(localProjectsStoreProvider);
    await store.toggleFavorite(account.id, project);
    state = store.readFavorites(account.id);
  }
}

final favoriteProjectsProvider =
    NotifierProvider<FavoriteProjectsController, List<Project>>(
      FavoriteProjectsController.new,
    );
