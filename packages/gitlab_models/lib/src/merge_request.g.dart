// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merge_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MergeRequest _$MergeRequestFromJson(Map<String, dynamic> json) =>
    _MergeRequest(
      id: (json['id'] as num).toInt(),
      iid: (json['iid'] as num).toInt(),
      title: json['title'] as String,
      state: json['state'] as String,
      sourceBranch: json['source_branch'] as String,
      targetBranch: json['target_branch'] as String,
      description: json['description'] as String?,
      author: json['author'] == null
          ? null
          : User.fromJson(json['author'] as Map<String, dynamic>),
      labels: json['labels'] == null
          ? const <Label>[]
          : Label.listFromJson(json['labels']),
      draft: json['draft'] as bool? ?? false,
      mergeStatus: json['merge_status'] as String?,
      commentCount: (json['user_notes_count'] as num?)?.toInt() ?? 0,
      webUrl: json['web_url'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MergeRequestToJson(_MergeRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'iid': instance.iid,
      'title': instance.title,
      'state': instance.state,
      'source_branch': instance.sourceBranch,
      'target_branch': instance.targetBranch,
      'description': instance.description,
      'author': instance.author?.toJson(),
      'labels': instance.labels.map((e) => e.toJson()).toList(),
      'draft': instance.draft,
      'merge_status': instance.mergeStatus,
      'user_notes_count': instance.commentCount,
      'web_url': instance.webUrl,
      'created_at': instance.createdAt?.toIso8601String(),
    };
