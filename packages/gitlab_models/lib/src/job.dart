import 'package:freezed_annotation/freezed_annotation.dart';

import 'ci_status.dart';

part 'job.freezed.dart';
part 'job.g.dart';

/// A CI/CD job within a pipeline.
@freezed
abstract class Job with _$Job {
  const factory Job({
    required int id,
    required String name,
    required String status,
    String? stage,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'finished_at') DateTime? finishedAt,
    @JsonKey(name: 'web_url') String? webUrl,
  }) = _Job;

  const Job._();

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  CiStatus get ciStatus => CiStatus.parse(status);

  /// A finished job can be retried.
  bool get canRetry => switch (ciStatus) {
    CiStatus.success || CiStatus.failed || CiStatus.canceled => true,
    _ => false,
  };

  /// An active job can be cancelled.
  bool get canCancel => switch (ciStatus) {
    CiStatus.running || CiStatus.pending || CiStatus.created => true,
    _ => false,
  };

  /// A manual job can be played.
  bool get canPlay => ciStatus == CiStatus.manual;
}
