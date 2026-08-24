/// A page of results plus the cursor needed to ask for the next one.
///
/// GitLab does not always report a total: keyset pagination omits it on large
/// collections, and offset pagination drops it past a threshold. So [total] and
/// [totalPages] are nullable, and callers must not build a UI that assumes a
/// page count exists.
class Paginated<T> {
  const Paginated({
    required this.items,
    this.nextPage,
    this.total,
    this.totalPages,
  });

  final List<T> items;

  /// Page number to request next, or null when this is the last page.
  final int? nextPage;

  final int? total;
  final int? totalPages;

  bool get hasMore => nextPage != null;

  /// Builds a page from a GitLab response and its headers.
  static Paginated<T> fromHeaders<T>(
    List<T> items,
    Map<String, List<String>> headers,
  ) {
    int? intHeader(String name) {
      final raw = headers[name]?.firstOrNull;
      if (raw == null || raw.isEmpty) {
        return null;
      }
      return int.tryParse(raw);
    }

    return Paginated<T>(
      items: items,
      nextPage: intHeader('x-next-page'),
      total: intHeader('x-total'),
      totalPages: intHeader('x-total-pages'),
    );
  }
}
