import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'account.freezed.dart';
part 'account.g.dart';

/// How an account authenticates: a personal access token entered by hand, or an
/// OAuth session obtained through the browser flow.
enum AuthMethod { pat, oauth }

/// A signed-in GitLab account: which instance, and who.
///
/// An account is identified by (instance URL, user id). The same username can
/// exist on two instances, and user ids are only unique within an instance, so
/// neither half identifies an account on its own.
///
/// This holds no token. The token lives in secure storage, keyed by the same
/// pair, so account metadata can be persisted in ordinary storage without
/// carrying a secret into it.
@freezed
abstract class Account with _$Account {
  const factory Account({
    required String instanceUrl,
    required User user,
    // Defaulted so accounts persisted before OAuth existed read back as PAT.
    @Default(AuthMethod.pat) AuthMethod authMethod,
    // The OAuth application id, kept for token refresh. Not a secret, so it may
    // live in ordinary account metadata; null for PAT accounts.
    @JsonKey(name: 'oauth_client_id') String? oauthClientId,
  }) = _Account;

  const Account._();

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  /// Stable key for this account, used to namespace its token and cache.
  ///
  /// The origin includes the port when it is not the scheme default, so a
  /// self-hosted instance on a custom port is a distinct account from one on
  /// the default port — dropping the port would let them collide and overwrite
  /// each other's token.
  String get id => '${canonicalOrigin(instanceUrl)}/${user.id}';

  /// The host, plus `:port` when the port is not the scheme default.
  static String canonicalOrigin(String instanceUrl) {
    final uri = Uri.parse(instanceUrl);
    final isDefaultPort =
        (uri.scheme == 'https' && uri.port == 443) ||
        (uri.scheme == 'http' && uri.port == 80);
    return isDefaultPort ? uri.host : '${uri.host}:${uri.port}';
  }
}
