// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Account _$AccountFromJson(Map<String, dynamic> json) => _Account(
  instanceUrl: json['instanceUrl'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  authMethod:
      $enumDecodeNullable(_$AuthMethodEnumMap, json['authMethod']) ??
      AuthMethod.pat,
  oauthClientId: json['oauth_client_id'] as String?,
);

Map<String, dynamic> _$AccountToJson(_Account instance) => <String, dynamic>{
  'instanceUrl': instance.instanceUrl,
  'user': instance.user.toJson(),
  'authMethod': _$AuthMethodEnumMap[instance.authMethod]!,
  'oauth_client_id': instance.oauthClientId,
};

const _$AuthMethodEnumMap = {AuthMethod.pat: 'pat', AuthMethod.oauth: 'oauth'};
