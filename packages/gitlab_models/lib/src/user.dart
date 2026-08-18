import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// A GitLab user.
///
/// GitLab returns snake_case field names, so every multi-word field is mapped
/// with [JsonKey] and kept camelCase on the Dart side. Fields that GitLab omits
/// depending on scope and permissions are nullable rather than defaulted, so a
/// missing value never reads as an empty one.
@freezed
abstract class User with _$User {
  const factory User({
    required int id,
    required String username,
    required String name,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'web_url') String? webUrl,
    String? state,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
