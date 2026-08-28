// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Group _$GroupFromJson(Map<String, dynamic> json) => _Group(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  fullPath: json['full_path'] as String,
  description: json['description'] as String?,
  visibility: json['visibility'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  webUrl: json['web_url'] as String?,
);

Map<String, dynamic> _$GroupToJson(_Group instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'full_path': instance.fullPath,
  'description': instance.description,
  'visibility': instance.visibility,
  'avatar_url': instance.avatarUrl,
  'web_url': instance.webUrl,
};
