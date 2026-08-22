import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'entitlement.dart';
import 'entitlement_store.dart';

/// Whether this build ships free with every feature.
///
/// Windows and macOS do: `.agents/docs/monetization.md` §1. This is one of the
/// few places `Platform` is the right thing to branch on — which store an
/// install came from is a distribution fact, not a layout one, so §10's
/// "decide on width, not platform" does not apply.
final freePlatformProvider = Provider<bool>((ref) {
  return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
});

final entitlementStoreProvider = Provider<EntitlementStore>((ref) {
  return EntitlementStore(ref.watch(sharedPreferencesProvider));
});

/// The store adapter. Overridden by the platform implementation once one
/// exists; until then nothing subscribes and every mobile build reads free.
final entitlementSourceProvider = Provider<EntitlementSource>((ref) {
  return const _NoSource();
});

class _NoSource implements EntitlementSource {
  const _NoSource();

  @override
  Future<Entitlement> read() async => Entitlement.free;
}

/// The current entitlement, and the only thing controllers should ask.
///
/// [build] never touches the network: it answers from the last known state so
/// the first frame is not waiting on a store. [refresh] brings that state up to
/// date, and is what a purchase or a restore triggers.
class EntitlementController extends Notifier<Entitlement> {
  @override
  Entitlement build() {
    if (ref.watch(freePlatformProvider)) {
      return Entitlement.subscribed;
    }
    return ref.watch(entitlementStoreProvider).read() ?? Entitlement.free;
  }

  /// Re-reads the store and persists the answer.
  ///
  /// A store that cannot be reached leaves the current state alone. That is
  /// the fail-open rule, and it cuts one way only: a subscriber keeps working
  /// offline, while someone who never paid is not upgraded because a network
  /// call failed. A store that answers [Entitlement.free] is believed — a
  /// lapsed subscription has to be able to lapse.
  Future<void> refresh() async {
    if (ref.read(freePlatformProvider)) {
      return;
    }
    final Entitlement fresh;
    try {
      fresh = await ref.read(entitlementSourceProvider).read();
    } catch (_) {
      return;
    }
    await ref.read(entitlementStoreProvider).write(fresh);
    state = fresh;
  }
}

final entitlementProvider =
    NotifierProvider<EntitlementController, Entitlement>(
      EntitlementController.new,
    );
