// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Todo _$TodoFromJson(Map<String, dynamic> json) => _Todo(
  id: (json['id'] as num).toInt(),
  state: json['state'] as String,
  actionName: json['action_name'] as String? ?? '',
  targetType: json['target_type'] as String?,
  targetUrl: json['target_url'] as String?,
  body: json['body'] as String?,
  author: json['author'] == null
      ? null
      : User.fromJson(json['author'] as Map<String, dynamic>),
  project: json['project'] == null
      ? null
      : Project.fromJson(json['project'] as Map<String, dynamic>),
  target: json['target'] == null
      ? null
      : TodoTarget.fromJson(json['target'] as Map<String, dynamic>),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$TodoToJson(_Todo instance) => <String, dynamic>{
  'id': instance.id,
  'state': instance.state,
  'action_name': instance.actionName,
  'target_type': instance.targetType,
  'target_url': instance.targetUrl,
  'body': instance.body,
  'author': instance.author?.toJson(),
  'project': instance.project?.toJson(),
  'target': instance.target?.toJson(),
  'created_at': instance.createdAt?.toIso8601String(),
};

_TodoTarget _$TodoTargetFromJson(Map<String, dynamic> json) => _TodoTarget(
  id: (json['id'] as num?)?.toInt(),
  iid: (json['iid'] as num?)?.toInt(),
  title: json['title'] as String?,
  state: json['state'] as String?,
);

Map<String, dynamic> _$TodoTargetToJson(_TodoTarget instance) =>
    <String, dynamic>{
      'id': instance.id,
      'iid': instance.iid,
      'title': instance.title,
      'state': instance.state,
    };
