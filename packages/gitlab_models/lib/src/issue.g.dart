// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Issue _$IssueFromJson(Map<String, dynamic> json) => _Issue(
  id: (json['id'] as num).toInt(),
  iid: (json['iid'] as num).toInt(),
  title: json['title'] as String,
  state: json['state'] as String,
  projectId: (json['project_id'] as num?)?.toInt(),
  description: json['description'] as String?,
  author: json['author'] == null
      ? null
      : User.fromJson(json['author'] as Map<String, dynamic>),
  labels: json['labels'] == null
      ? const <Label>[]
      : Label.listFromJson(json['labels']),
  webUrl: json['web_url'] as String?,
  commentCount: (json['user_notes_count'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$IssueToJson(_Issue instance) => <String, dynamic>{
  'id': instance.id,
  'iid': instance.iid,
  'title': instance.title,
  'state': instance.state,
  'project_id': instance.projectId,
  'description': instance.description,
  'author': instance.author?.toJson(),
  'labels': instance.labels.map((e) => e.toJson()).toList(),
  'web_url': instance.webUrl,
  'user_notes_count': instance.commentCount,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
