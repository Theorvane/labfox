// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Branch _$BranchFromJson(Map<String, dynamic> json) => _Branch(
  name: json['name'] as String,
  isDefault: json['default'] as bool? ?? false,
  isProtected: json['protected'] as bool? ?? false,
  commit: json['commit'] == null
      ? null
      : Commit.fromJson(json['commit'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BranchToJson(_Branch instance) => <String, dynamic>{
  'name': instance.name,
  'default': instance.isDefault,
  'protected': instance.isProtected,
  'commit': instance.commit?.toJson(),
};
