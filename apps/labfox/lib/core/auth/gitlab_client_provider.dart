import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';

import 'auth_controller.dart';
import 'auth_providers.dart';

/// A GitLabClient bound to the signed-in account, or null when signed out.
///
/// Rebuilds when the account changes, so switching or signing out replaces the
/// client rather than mutating one in flight — a request cannot end up
/// authenticated as a previous account.
final gitLabClientProvider = FutureProvider<GitLabClient?>((ref) async {
  final account = ref.watch(currentAccountProvider);
  if (account == null) {
    return null;
  }
  final token = await ref.watch(authRepositoryProvider).tokenFor(account);
  if (token == null) {
    return null;
  }
  final client = GitLabClient(baseUrl: account.instanceUrl, token: token);
  ref.onDispose(client.close);
  return client;
});
