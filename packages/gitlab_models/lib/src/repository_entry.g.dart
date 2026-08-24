// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RepositoryEntry _$RepositoryEntryFromJson(Map<String, dynamic> json) =>
    _RepositoryEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      path: json['path'] as String,
    );

Map<String, dynamic> _$RepositoryEntryToJson(_RepositoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'path': instance.path,
    };
