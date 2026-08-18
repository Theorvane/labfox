// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Note _$NoteFromJson(Map<String, dynamic> json) => _Note(
  id: (json['id'] as num).toInt(),
  body: json['body'] as String,
  isSystem: json['system'] as bool? ?? false,
  author: json['author'] == null
      ? null
      : User.fromJson(json['author'] as Map<String, dynamic>),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$NoteToJson(_Note instance) => <String, dynamic>{
  'id': instance.id,
  'body': instance.body,
  'system': instance.isSystem,
  'author': instance.author?.toJson(),
  'created_at': instance.createdAt?.toIso8601String(),
};
