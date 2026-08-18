/// Base class for every error this package surfaces.
///
/// Callers never see a raw `DioException`: transport details are translated
/// here so the UI can branch on meaning rather than on status codes.
sealed class GitLabException implements Exception {
  const GitLabException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => '$runtimeType: $message';
}

/// The token is missing, expired or rejected. HTTP 401.
class GitLabAuthException extends GitLabException {
  const GitLabAuthException(super.message, {super.statusCode});
}

/// The token is valid but lacks the scope or role for this action. HTTP 403.
class GitLabForbiddenException extends GitLabException {
  const GitLabForbiddenException(super.message, {super.statusCode});
}

/// The resource does not exist, or is private to this token. HTTP 404.
///
/// GitLab deliberately returns 404 rather than 403 for resources a token may
/// not see, so "not found" and "no permission" cannot always be told apart.
class GitLabNotFoundException extends GitLabException {
  const GitLabNotFoundException(super.message, {super.statusCode});
}

/// Rate limited. HTTP 429.
class GitLabRateLimitException extends GitLabException {
  const GitLabRateLimitException(
    super.message, {
    super.statusCode,
    this.retryAfter,
  });

  /// Value of the `Retry-After` header when the instance sent one.
  final Duration? retryAfter;
}

/// The instance failed. HTTP 5xx.
class GitLabServerException extends GitLabException {
  const GitLabServerException(super.message, {super.statusCode});
}

/// The merge request cannot be merged in its current state (405 / 406 / 409):
/// not mergeable, needs a rebase, or a pipeline/approval is missing.
class GitLabNotMergeableException extends GitLabException {
  const GitLabNotMergeableException(super.message, {super.statusCode});
}

/// The instance could not be reached at all.
///
/// Kept separate from every HTTP failure because self-hosted instances fail
/// this way constantly — VPN down, private DNS, corporate proxy, a certificate
/// the device does not trust — and "cannot connect" needs different advice than
/// "your token is wrong".
class GitLabConnectionException extends GitLabException {
  const GitLabConnectionException(super.message);
}
