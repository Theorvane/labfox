import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores GitLab credentials in the platform keychain.
///
/// Tokens never go anywhere else. Not the Drift cache, not SharedPreferences,
/// not a log line. This class is the only path in or out, so there is a single
/// place to audit.
class CredentialStore {
  CredentialStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  final FlutterSecureStorage _storage;

  /// Keys are namespaced per account.
  ///
  /// LabFox supports several accounts at once, including the same username on
  /// two different instances, so the instance URL has to be part of the key or
  /// one account would silently overwrite another.
  static String keyFor({
    required String instanceUrl,
    required int userId,
    required String kind,
  }) {
    final host = Uri.parse(instanceUrl).host;
    if (host.isEmpty) {
      throw ArgumentError.value(
        instanceUrl,
        'instanceUrl',
        'must include a host',
      );
    }
    return 'labfox/$host/$userId/$kind';
  }

  Future<void> writeToken({
    required String instanceUrl,
    required int userId,
    required String kind,
    required String token,
  }) {
    return _storage.write(
      key: keyFor(instanceUrl: instanceUrl, userId: userId, kind: kind),
      value: token,
    );
  }

  Future<String?> readToken({
    required String instanceUrl,
    required int userId,
    required String kind,
  }) {
    return _storage.read(
      key: keyFor(instanceUrl: instanceUrl, userId: userId, kind: kind),
    );
  }

  Future<void> deleteAccount({
    required String instanceUrl,
    required int userId,
  }) async {
    for (final kind in const ['pat', 'oauth_access', 'oauth_refresh']) {
      await _storage.delete(
        key: keyFor(instanceUrl: instanceUrl, userId: userId, kind: kind),
      );
    }
  }
}
