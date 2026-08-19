import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  group('OAuthApi.authorizationUrl', () {
    test('builds the authorize URL with PKCE and CSRF state', () {
      final url = OAuthApi.authorizationUrl(
        instanceUrl: 'https://gitlab.com',
        clientId: 'app-1',
        redirectUri: 'labfox://oauth-callback',
        state: 'xyz',
        codeChallenge: 'chal',
        scope: 'api',
      );

      expect(url.path, '/oauth/authorize');
      expect(url.host, 'gitlab.com');
      final q = url.queryParameters;
      expect(q['client_id'], 'app-1');
      expect(q['redirect_uri'], 'labfox://oauth-callback');
      expect(q['response_type'], 'code');
      expect(q['state'], 'xyz');
      expect(q['scope'], 'api');
      expect(q['code_challenge'], 'chal');
      expect(q['code_challenge_method'], 'S256');
    });

    test('keeps a self-hosted host and custom port', () {
      final url = OAuthApi.authorizationUrl(
        instanceUrl: 'https://git.example.com:8443',
        clientId: 'a',
        redirectUri: 'labfox://oauth-callback',
        state: 's',
        codeChallenge: 'c',
      );
      expect(url.host, 'git.example.com');
      expect(url.port, 8443);
    });
  });

  group('OAuthApi.exchangeCode', () {
    test('posts the code and PKCE verifier to the token endpoint', () async {
      late RequestOptions captured;
      final api = _api((o) {
        captured = o;
        return (
          status: 200,
          body: {
            'access_token': 'at',
            'refresh_token': 'rt',
            'token_type': 'bearer',
            'expires_in': 7200,
            'created_at': 1607635748,
          },
        );
      });

      final token = await api.exchangeCode(
        instanceUrl: 'https://gitlab.com',
        clientId: 'app-1',
        code: 'the-code',
        redirectUri: 'labfox://oauth-callback',
        codeVerifier: 'verifier',
      );

      expect(captured.method, 'POST');
      expect(captured.uri.toString(), 'https://gitlab.com/oauth/token');
      expect(
        captured.headers[Headers.contentTypeHeader],
        Headers.formUrlEncodedContentType,
      );
      final body = captured.data as Map<String, dynamic>;
      expect(body['grant_type'], 'authorization_code');
      expect(body['client_id'], 'app-1');
      expect(body['code'], 'the-code');
      expect(body['code_verifier'], 'verifier');
      expect(body['redirect_uri'], 'labfox://oauth-callback');
      expect(token.accessToken, 'at');
      expect(token.refreshToken, 'rt');
    });

    test('maps an invalid_grant to unauthorized', () async {
      final api = _api((_) => (status: 401, body: {'error': 'invalid_grant'}));
      await expectLater(
        api.exchangeCode(
          instanceUrl: 'https://gitlab.com',
          clientId: 'a',
          code: 'bad',
          redirectUri: 'labfox://oauth-callback',
          codeVerifier: 'v',
        ),
        throwsA(isA<GitLabAuthException>()),
      );
    });
  });

  group('OAuthApi.refresh', () {
    test('posts the refresh grant to the token endpoint', () async {
      late RequestOptions captured;
      final api = _api((o) {
        captured = o;
        return (
          status: 200,
          body: {
            'access_token': 'at2',
            'refresh_token': 'rt2',
            'expires_in': 7200,
            'created_at': 1607700000,
          },
        );
      });

      final token = await api.refresh(
        instanceUrl: 'https://gitlab.com',
        clientId: 'app-1',
        refreshToken: 'rt',
      );

      final body = captured.data as Map<String, dynamic>;
      expect(body['grant_type'], 'refresh_token');
      expect(body['refresh_token'], 'rt');
      expect(body['client_id'], 'app-1');
      expect(token.accessToken, 'at2');
    });
  });
}

OAuthApi _api(({int status, Object? body}) Function(RequestOptions) handler) {
  final dio = Dio(BaseOptions(validateStatus: (s) => s != null && s < 500));
  dio.httpClientAdapter = _Adapter(handler);
  return OAuthApi(dio);
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);
  final ({int status, Object? body}) Function(RequestOptions) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final r = handler(options);
    return ResponseBody.fromString(
      r.body == null ? '' : json.encode(r.body),
      r.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
