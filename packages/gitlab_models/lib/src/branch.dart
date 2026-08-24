import 'package:freezed_annotation/freezed_annotation.dart';

import 'commit.dart';

part 'branch.freezed.dart';
part 'branch.g.dart';

/// A repository branch and its tip commit.
@freezed
abstract class Branch with _$Branch {
  const factory Branch({
    required String name,
    @JsonKey(name: 'default') @Default(false) bool isDefault,
    @JsonKey(name: 'protected') @Default(false) bool isProtected,
    Commit? commit,
  }) = _Branch;

  factory Branch.fromJson(Map<String, dynamic> json) => _$BranchFromJson(json);
}
