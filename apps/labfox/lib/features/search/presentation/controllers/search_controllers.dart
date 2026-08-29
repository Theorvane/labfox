import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/analytics/analytics.dart';
import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/search_repository.dart';

final searchRepositoryProvider = FutureProvider<SearchRepository?>((ref) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : SearchRepository(client);
});

/// Identifies a search: which scope, which term.
class SearchQuery {
  const SearchQuery({required this.scope, required this.text});

  final SearchScope scope;
  final String text;

  @override
  bool operator ==(Object other) =>
      other is SearchQuery && other.scope == scope && other.text == text;

  @override
  int get hashCode => Object.hash(scope, text);
}

/// Runs a search and pages through its ranked results.
///
/// A blank term yields nothing rather than searching for everything. Ranked
/// results are paged, not fetched all at once: [loadMore] appends the next
/// page so the user reaches results past the first page without truncation.
class SearchController extends FamilyAsyncNotifier<SearchResults, SearchQuery> {
  @override
  Future<SearchResults> build(SearchQuery arg) async {
    if (arg.text.trim().isEmpty) {
      return const SearchResults(items: []);
    }
    final repo = await ref.watch(searchRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    // The scope tells us which search people actually use. The term is what
    // they typed and never leaves the device (`PRIVACY.md`).
    unawaited(
      ref.read(analyticsProvider).track('search', {'scope': arg.scope.name}),
    );
    return repo.search(arg.scope, arg.text);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.nextPage == null || current.loadingMore) {
      return;
    }
    state = AsyncData(
      current.copyWith(loadingMore: true, loadMoreFailed: false),
    );
    try {
      final repo = await ref.read(searchRepositoryProvider.future);
      if (repo == null) {
        throw StateError('No authenticated account');
      }
      final next = await repo.search(
        arg.scope,
        arg.text,
        page: current.nextPage!,
      );
      state = AsyncData(
        SearchResults(
          items: [...current.items, ...next.items],
          nextPage: next.nextPage,
        ),
      );
    } catch (_) {
      // Keep the loaded pages and flag a recoverable failure rather than
      // letting the error escape and leave the button falsely enabled.
      state = AsyncData(
        current.copyWith(loadingMore: false, loadMoreFailed: true),
      );
    }
  }
}

final searchControllerProvider =
    AsyncNotifierProvider.family<SearchController, SearchResults, SearchQuery>(
      SearchController.new,
    );
