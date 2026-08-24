import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../gitlab_client.dart';

/// The OAuth 2.0 endpoints on a GitLab instance root (`/oauth/...`), separate
/// from the versioned `/api/v4` surface [GitLabClient] wraps.
///
/// This runs before an account exists, so it is standalone: it takes the
/// instance URL on each call rather than being bound to one client.
class OAuthApi {
  const OAuthApi(this._dio);

  final Dio _dio;

  /// The authorization URL to open in the browser. PKCE ([codeChallenge]) and
  /// [state] make the flow safe for a public client with no secret.
  static Uri authorizationUrl({
    required String instanceUrl,
    required String clientId,
    required String redirectUri,
    required String state,
    required String codeChallenge,
    String scope = 'api',
  }) {
    final root = _root(instanceUrl);
    return Uri.parse('$root/oauth/authorize').replace(
      queryParameters: {
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'response_type': 'code',
        'state': state,
        'scope': scope,
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
      },
    );
  }

  /// Exchanges an authorization code for a token set (PKCE, no client secret).
  Future<OAuthToken> exchangeCode({
    required String instanceUrl,
    required String clientId,
    required String code,
    required String redirectUri,
    required String codeVerifier,
  }) {
    return _token(instanceUrl, {
      'grant_type': 'authorization_code',
      'client_id': clientId,
      'code': code,
      'redirect_uri': redirectUri,
      'code_verifier': codeVerifier,
    });
  }

  /// Trades a refresh token for a fresh token set.
  Future<OAuthToken> refresh({
    required String instanceUrl,
    required String clientId,
    required String refreshToken,
  }) {
    return _token(instanceUrl, {
      'grant_type': 'refresh_token',
      'client_id': clientId,
      'refresh_token': refreshToken,
    });
  }

  Future<OAuthToken> _token(
    String instanceUrl,
    Map<String, String> form,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '${_root(instanceUrl)}/oauth/token',
        data: form,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final data = response.data;
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'completing sign-in',
        );
      }
      return OAuthToken.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'completing sign-in');
    }
  }

  static String _root(String instanceUrl) =>
      instanceUrl.trim().replaceAll(RegExp(r'/+$'), '');
}
