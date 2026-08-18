import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  group('GitLabClient.apiBaseUrl', () {
    test('appends the REST path to an instance URL', () {
      expect(
        GitLabClient.apiBaseUrl('https://git.company.com'),
        'https://git.company.com/api/v4',
      );
    });

    test('works for gitlab.com without treating it specially', () {
      // gitlab.com is just another instance; nothing may hardcode it.
      expect(
        GitLabClient.apiBaseUrl('https://gitlab.com'),
        'https://gitlab.com/api/v4',
      );
    });

    test('tolerates trailing slashes, which people paste', () {
      expect(
        GitLabClient.apiBaseUrl('https://git.company.com///'),
        'https://git.company.com/api/v4',
      );
    });

    test('keeps a URL that already points at the API', () {
      expect(
        GitLabClient.apiBaseUrl('https://git.company.com/api/v4'),
        'https://git.company.com/api/v4',
      );
    });

    test('preserves a subpath install', () {
      // Self-hosted GitLab is often mounted under a path rather than a host.
      expect(
        GitLabClient.apiBaseUrl('https://intra.company.com/gitlab'),
        'https://intra.company.com/gitlab/api/v4',
      );
    });

    test('rejects an empty instance URL', () {
      expect(() => GitLabClient.apiBaseUrl('   '), throwsArgumentError);
    });
  });

  group('mapStatus', () {
    test('401 becomes an auth failure', () {
      expect(mapStatus(401, const {}), isA<GitLabAuthException>());
    });

    test('403 is kept separate from 401', () {
      // A bad token and an insufficient scope need different advice.
      expect(mapStatus(403, const {}), isA<GitLabForbiddenException>());
    });

    test('404 becomes a not-found failure', () {
      expect(mapStatus(404, const {}), isA<GitLabNotFoundException>());
    });

    test('429 carries Retry-After when the instance sends it', () {
      final error = mapStatus(429, const {
        'retry-after': ['30'],
      });

      expect(error, isA<GitLabRateLimitException>());
      expect(
        (error as GitLabRateLimitException).retryAfter,
        const Duration(seconds: 30),
      );
    });

    test('429 without Retry-After leaves the delay unknown', () {
      final error = mapStatus(429, const {}) as GitLabRateLimitException;
      expect(error.retryAfter, isNull);
    });

    test('500 becomes a server failure', () {
      expect(mapStatus(500, const {}), isA<GitLabServerException>());
    });
  });

  group('Paginated', () {
    test('reads the cursor from GitLab headers', () {
      final page = Paginated.fromHeaders(
        const [1, 2, 3],
        const {
          'x-next-page': ['2'],
          'x-total': ['57'],
          'x-total-pages': ['20'],
        },
      );

      expect(page.items, hasLength(3));
      expect(page.nextPage, 2);
      expect(page.total, 57);
      expect(page.hasMore, isTrue);
    });

    test('handles the last page, where x-next-page is empty', () {
      final page = Paginated.fromHeaders(
        const [1],
        const {
          'x-next-page': [''],
        },
      );

      expect(page.nextPage, isNull);
      expect(page.hasMore, isFalse);
    });

    test('survives a response with no pagination headers at all', () {
      // Keyset pagination omits totals on large collections, so the UI must
      // never assume a page count exists.
      final page = Paginated.fromHeaders(const [1], const {});

      expect(page.total, isNull);
      expect(page.totalPages, isNull);
      expect(page.hasMore, isFalse);
    });
  });
}
