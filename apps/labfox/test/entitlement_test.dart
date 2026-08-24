import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/core/auth/auth_providers.dart';
import 'package:labfox/core/entitlement/entitlement.dart';
import 'package:labfox/core/entitlement/entitlement_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A store adapter stand-in: returns what the test tells it to, or throws.
class _FakeSource implements EntitlementSource {
  _FakeSource(this.result);

  Entitlement? result;
  Object? error;
  int reads = 0;

  @override
  Future<Entitlement> read() async {
    reads++;
    if (error != null) {
      throw error!;
    }
    return result!;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer containerWith({
    required _FakeSource source,
    required bool isFreePlatform,
  }) {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        entitlementSourceProvider.overrideWithValue(source),
        freePlatformProvider.overrideWithValue(isFreePlatform),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('a fresh install with no cache is free', () {
    final container = containerWith(
      source: _FakeSource(Entitlement.subscribed),
      isFreePlatform: false,
    );

    expect(container.read(entitlementProvider), Entitlement.free);
  });

  test('a desktop build is entitled without consulting the store', () {
    final source = _FakeSource(Entitlement.free);
    final container = containerWith(source: source, isFreePlatform: true);

    // Windows and macOS ship free with every feature, so there is nothing to
    // ask a store about — and no store to ask on Windows.
    expect(container.read(entitlementProvider), Entitlement.subscribed);
    expect(source.reads, 0);
  });

  test('a successful refresh is persisted and survives a restart', () async {
    final source = _FakeSource(Entitlement.subscribed);
    final container = containerWith(source: source, isFreePlatform: false);

    await container.read(entitlementProvider.notifier).refresh();
    expect(container.read(entitlementProvider), Entitlement.subscribed);

    // A new container stands in for the next launch.
    final relaunched = containerWith(
      source: _FakeSource(Entitlement.subscribed),
      isFreePlatform: false,
    );
    expect(relaunched.read(entitlementProvider), Entitlement.subscribed);
  });

  test('an unreachable store leaves a subscriber entitled', () async {
    final source = _FakeSource(Entitlement.subscribed);
    final container = containerWith(source: source, isFreePlatform: false);
    await container.read(entitlementProvider.notifier).refresh();

    // A receipt check that times out on a train must not stop a paying user
    // from merging.
    source.error = Exception('store unreachable');
    await container.read(entitlementProvider.notifier).refresh();

    expect(container.read(entitlementProvider), Entitlement.subscribed);
  });

  test(
    'an unreachable store does not entitle someone who never paid',
    () async {
      final source = _FakeSource(Entitlement.free)
        ..error = Exception('store unreachable');
      final container = containerWith(source: source, isFreePlatform: false);

      await container.read(entitlementProvider.notifier).refresh();

      // Fail-open means the last known answer survives, not that everyone is
      // upgraded whenever the store is down.
      expect(container.read(entitlementProvider), Entitlement.free);
    },
  );

  test(
    'a lapsed subscription is honoured when the store actually says so',
    () async {
      final source = _FakeSource(Entitlement.subscribed);
      final container = containerWith(source: source, isFreePlatform: false);
      await container.read(entitlementProvider.notifier).refresh();

      source.result = Entitlement.free;
      await container.read(entitlementProvider.notifier).refresh();

      expect(container.read(entitlementProvider), Entitlement.free);
    },
  );

  test('a free platform never even constructs the store adapter', () {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        freePlatformProvider.overrideWithValue(true),
        // Windows has no store to talk to, and the real adapter would throw
        // there. Constructing it at all is the bug this guards against.
        entitlementSourceProvider.overrideWith(
          (ref) => throw StateError('the store adapter must not be built here'),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(entitlementProvider), Entitlement.subscribed);
    expect(container.read(entitlementProvider.notifier).refresh(), completes);
  });
}
