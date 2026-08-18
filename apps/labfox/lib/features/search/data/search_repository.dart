import 'package:gitlab_api/gitlab_api.dart';

/// What kind of thing the user is searching for.
enum SearchScope { projects, issues, mergeRequests }

/// One page of search results plus the cursor to the next page.
///
/// Results are a mixed list of [Project], [Issue] or [MergeRequest] depending
/// on the scope; the screen renders each by its runtime type.
class SearchResults {
  const SearchResults({required this.items, this.nextPage});

  final List<Object> items;
  final int? nextPage;

  bool get hasMore => nextPage != null;
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
