/// A normalized CI/CD status, shared by pipelines and jobs.
///
/// GitLab uses a handful of overlapping status strings for both; this maps them
/// to one small set the UI can render with a consistent icon and colour. An
/// unrecognized status becomes [other] rather than crashing.
enum CiStatus {
  success,
  failed,
  running,
  pending,
  canceled,
  skipped,
  manual,
  created,
  other;

  static CiStatus parse(String? raw) {
    return switch (raw) {
      'success' => CiStatus.success,
      'failed' => CiStatus.failed,
      'running' => CiStatus.running,
      'pending' => CiStatus.pending,
      'canceled' || 'cancelled' => CiStatus.canceled,
      'skipped' => CiStatus.skipped,
      'manual' => CiStatus.manual,
      'created' || 'preparing' || 'scheduled' => CiStatus.created,
      _ => CiStatus.other,
    };
  }
}
