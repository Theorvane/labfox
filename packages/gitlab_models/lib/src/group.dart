import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';
part 'group.g.dart';

/// A GitLab group visible to the signed-in user.
@freezed
abstract class Group with _$Group {
  const factory Group({
    required int id,
    required String name,
    @JsonKey(name: 'full_path') required String fullPath,
    String? description,
    String? visibility,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'web_url') String? webUrl,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}
