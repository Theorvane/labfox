import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where events go and which project they belong to.
///
/// Defaults point at the LabFox OpenPanel project and can be overridden at
/// build time (`--dart-define=OPENPANEL_URL=... OPENPANEL_CLIENT_ID=...`).
/// Only the public client id is used here — the server-events secret is never
/// needed by the app and must never enter this repository (AGENTS §7).
class AnalyticsConfig {
  const AnalyticsConfig({
    this.endpoint = const String.fromEnvironment(
      'OPENPANEL_URL',
      defaultValue: 'https://panel.sanhouse.kr/api',
    ),
    this.clientId = const String.fromEnvironment(
      'OPENPANEL_CLIENT_ID',
      defaultValue: '70da32fe-76b3-4547-9d02-431e08abc3f4',
    ),
  });

  final String endpoint;
  final String clientId;
}

/// Fire-and-forget product analytics against OpenPanel.
///
/// Owns its own Dio — never the GitLab client — so an Authorization header
/// can never ride along to the analytics host. Failures are swallowed: a slow
/// or down panel must never surface in the UI. Events carry no PII: no
/// usernames, ids, titles, tokens, or full URLs.
class Analytics {
  Analytics({required AnalyticsConfig config, Dio? dio})
    : _config = config,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ),
          );

  final AnalyticsConfig _config;
  final Dio _dio;

  Future<void> track(String name, [Map<String, Object?>? properties]) async {
    try {
      await _dio.post<dynamic>(
        '${_config.endpoint}/track',
        options: Options(
          headers: {
            'openpanel-client-id': _config.clientId,
            // OpenPanel validates client ingestion against a stable origin.
            // This identifies the app, not the signed-in user.
            'origin': 'app://labfox',
          },
          contentType: Headers.jsonContentType,
        ),
        data: {
          'type': 'track',
          'payload': {'name': name, 'properties': properties ?? const {}},
        },
      );
    } catch (_) {
      // Analytics must never break the app; drop the event.
    }
  }
}

/// Collapses numeric path segments (`/projects/42` → `/projects/:id`) so a
/// screen-view route never carries an identifying or high-cardinality value.
String sanitizeRoute(String path) {
  return path
      .split('/')
      .map((segment) => int.tryParse(segment) == null ? segment : ':id')
      .join('/');
}

final analyticsProvider = Provider<Analytics>((ref) {
  return Analytics(config: const AnalyticsConfig());
});
