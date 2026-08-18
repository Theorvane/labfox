import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'account.freezed.dart';
part 'account.g.dart';

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
  const factory Account({required String instanceUrl, required User user}) =
      _Account;

  const Account._();

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  /// Stable key for this account, used to namespace its token and cache.
  String get id => '${Uri.parse(instanceUrl).host}/${user.id}';
}
