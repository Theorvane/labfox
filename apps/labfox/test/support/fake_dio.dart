import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A Dio whose responses are canned, so client code is tested without a network.
///
/// [handler] receives the request path and returns (statusCode, jsonBody).
Dio fakeDio(
  ({int status, Object? body}) Function(RequestOptions options) handler,
) {
  final dio = Dio(
    BaseOptions(validateStatus: (status) => status != null && status < 500),
  );
  dio.httpClientAdapter = _FakeAdapter(handler);
  return dio;
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ({int status, Object? body}) Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final result = handler(options);
    final payload = result.body == null ? '' : json.encode(result.body);
    return ResponseBody.fromString(
      payload,
      result.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
