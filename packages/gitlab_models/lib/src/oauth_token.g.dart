// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oauth_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OAuthToken _$OAuthTokenFromJson(Map<String, dynamic> json) => _OAuthToken(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String?,
  tokenType: json['token_type'] as String? ?? 'bearer',
  expiresIn: (json['expires_in'] as num?)?.toInt(),
  createdAt: (json['created_at'] as num?)?.toInt(),
  scope: json['scope'] as String?,
);

Map<String, dynamic> _$OAuthTokenToJson(_OAuthToken instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
      'created_at': instance.createdAt,
      'scope': instance.scope,
    };
