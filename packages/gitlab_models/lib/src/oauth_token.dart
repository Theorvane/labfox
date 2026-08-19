import 'package:freezed_annotation/freezed_annotation.dart';

part 'oauth_token.freezed.dart';
part 'oauth_token.g.dart';

/// An OAuth 2.0 token set from GitLab's `/oauth/token` endpoint.
///
/// [createdAt] and [expiresIn] are seconds (a unix timestamp and a duration),
/// exactly as GitLab returns them, so expiry can be judged without parsing a
/// date. The access token is short-lived; [refreshToken] buys a new one.
@freezed
abstract class OAuthToken with _$OAuthToken {
  const factory OAuthToken({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') String? refreshToken,
    @JsonKey(name: 'token_type') @Default('bearer') String tokenType,
    @JsonKey(name: 'expires_in') int? expiresIn,
    @JsonKey(name: 'created_at') int? createdAt,
    String? scope,
  }) = _OAuthToken;

  const OAuthToken._();

  factory OAuthToken.fromJson(Map<String, dynamic> json) =>
      _$OAuthTokenFromJson(json);

  /// Whether the token is expired at [nowEpochSeconds], treating anything
  /// within [leewaySeconds] of the hard expiry as already expired so a refresh
  /// happens before a request can fail mid-flight.
  ///
  /// A token with no expiry information is never considered expired.
  bool isExpiredAt(int nowEpochSeconds, {int leewaySeconds = 0}) {
    final created = createdAt;
    final lifetime = expiresIn;
    if (created == null || lifetime == null) {
      return false;
    }
    return nowEpochSeconds >= created + lifetime - leewaySeconds;
  }
}
