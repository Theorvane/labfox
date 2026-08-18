import 'package:freezed_annotation/freezed_annotation.dart';

import 'ci_status.dart';

part 'pipeline.freezed.dart';
part 'pipeline.g.dart';

/// A CI/CD pipeline.
@freezed
abstract class Pipeline with _$Pipeline {
  const factory Pipeline({
    required int id,
    required String status,
    String? ref,
    String? sha,
    @JsonKey(name: 'web_url') String? webUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Pipeline;

  const Pipeline._();

  factory Pipeline.fromJson(Map<String, dynamic> json) =>
      _$PipelineFromJson(json);

  CiStatus get ciStatus => CiStatus.parse(status);

  /// The short SHA a user sees, or null when the pipeline has no commit.
  String? get shortSha {
    final value = sha;
    if (value == null) {
      return null;
    }
    return value.length <= 8 ? value : value.substring(0, 8);
  }

  /// A finished pipeline can be retried.
  bool get canRetry => switch (ciStatus) {
    CiStatus.success || CiStatus.failed || CiStatus.canceled => true,
    _ => false,
  };

  /// An active pipeline can be cancelled.
  bool get canCancel => switch (ciStatus) {
    CiStatus.running || CiStatus.pending || CiStatus.created => true,
    _ => false,
  };
}
