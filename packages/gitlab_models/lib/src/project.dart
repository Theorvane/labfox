import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

/// A GitLab project.
///
/// GitLab returns far more than this; LabFox models the fields the list and
/// overview actually show. Unknown fields are ignored, and fields GitLab omits
/// depending on scope are nullable, so a reduced payload never reads as empty.
@freezed
abstract class Project with _$Project {
  const factory Project({
    required int id,
    required String name,
    @JsonKey(name: 'path_with_namespace') required String pathWithNamespace,
    String? description,
    // Always shown as a number in the UI, so absent means zero, not unknown.
    @JsonKey(name: 'star_count') @Default(0) int starCount,
    String? visibility,
    @JsonKey(name: 'default_branch') String? defaultBranch,
    // Null when GitLab omits the count on a reduced payload — unknown, not
    // zero, so the UI hides it instead of showing a false 0.
    @JsonKey(name: 'open_issues_count') int? openIssuesCount,
    @JsonKey(name: 'forks_count') int? forksCount,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'web_url') String? webUrl,
    @JsonKey(name: 'last_activity_at') DateTime? lastActivityAt,
  }) = _Project;

  const Project._();

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// The namespace portion of `path_with_namespace` — everything before the
  /// project name. Shown under the name as the human identifier.
  String get namespace {
    final lastSlash = pathWithNamespace.lastIndexOf('/');
    return lastSlash <= 0 ? '' : pathWithNamespace.substring(0, lastSlash);
  }
}
