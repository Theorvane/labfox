// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Project _$ProjectFromJson(Map<String, dynamic> json) => _Project(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  pathWithNamespace: json['path_with_namespace'] as String,
  description: json['description'] as String?,
  starCount: (json['star_count'] as num?)?.toInt() ?? 0,
  visibility: json['visibility'] as String?,
  defaultBranch: json['default_branch'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  webUrl: json['web_url'] as String?,
  lastActivityAt: json['last_activity_at'] == null
      ? null
      : DateTime.parse(json['last_activity_at'] as String),
);

Map<String, dynamic> _$ProjectToJson(_Project instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'path_with_namespace': instance.pathWithNamespace,
  'description': instance.description,
  'star_count': instance.starCount,
  'visibility': instance.visibility,
  'default_branch': instance.defaultBranch,
  'avatar_url': instance.avatarUrl,
  'web_url': instance.webUrl,
  'last_activity_at': instance.lastActivityAt?.toIso8601String(),
};
