import 'package:gitlab_api/gitlab_api.dart';

/// What kind of thing the user is searching for.
enum SearchScope { projects, issues, mergeRequests }

/// The accumulated search results plus the cursor to the next page and the
/// status of an in-flight or failed load-more.
///
/// Results are a mixed list of [Project], [Issue] or [MergeRequest] depending
/// on the scope; the screen renders each by its runtime type. [loadingMore]
/// and [loadMoreFailed] let the screen disable the button while a page loads
/// and offer a retry when one fails, instead of dropping the error.
class SearchResults {
  const SearchResults({
    required this.items,
    this.nextPage,
    this.loadingMore = false,
    this.loadMoreFailed = false,
  });

  final List<Object> items;
  final int? nextPage;
  final bool loadingMore;
  final bool loadMoreFailed;

  bool get hasMore => nextPage != null;

  SearchResults copyWith({bool? loadingMore, bool? loadMoreFailed}) {
    return SearchResults(
      items: items,
      nextPage: nextPage,
      loadingMore: loadingMore ?? this.loadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }
}

/// Runs global search for one scope at a time.
class SearchRepository {
  SearchRepository(this._client);

  final GitLabClient _client;

  Future<SearchResults> search(
    SearchScope scope,
    String query, {
    int page = 1,
  }) async {
    switch (scope) {
      case SearchScope.projects:
        final p = await _client.search.projects(query, page: page);
        return SearchResults(items: p.items, nextPage: p.nextPage);
      case SearchScope.issues:
        final p = await _client.search.issues(query, page: page);
        return SearchResults(items: p.items, nextPage: p.nextPage);
      case SearchScope.mergeRequests:
        final p = await _client.search.mergeRequests(query, page: page);
        return SearchResults(items: p.items, nextPage: p.nextPage);
    }
  }
}
