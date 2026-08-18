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
  }) = _Job;

  const Job._();

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  CiStatus get ciStatus => CiStatus.parse(status);
}
