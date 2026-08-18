import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_store.dart';
import 'auth_repository.dart';

/// Overridden in `main` once SharedPreferences has loaded, and in tests with a
/// fake. Reading it before that throws, which is deliberate: nothing should run
/// before persistence is ready.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final credentialStoreProvider = Provider<CredentialStore>((ref) {
  return CredentialStore();
});

final accountStoreProvider = Provider<AccountStore>((ref) {
  return AccountStore(ref.watch(sharedPreferencesProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    accountStore: ref.watch(accountStoreProvider),
    credentialStore: ref.watch(credentialStoreProvider),
  );
});
