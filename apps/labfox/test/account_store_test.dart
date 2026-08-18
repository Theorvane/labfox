import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/auth/account_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Account _account(String host, int id, String username) => Account(
  instanceUrl: 'https://$host',
  user: User(id: id, username: username, name: username),
);

Future<AccountStore> _store() async {
  SharedPreferences.setMockInitialValues({});
  return AccountStore(await SharedPreferences.getInstance());
}

void main() {
  test('starts empty', () async {
    final store = await _store();
    expect(store.readAccounts(), isEmpty);
    expect(store.readActive(), isNull);
  });

  test('adding an account makes it active and lists it', () async {
    final store = await _store();
    final a = _account('gitlab.com', 1, 'jungwon');

    await store.add(a);

    expect(store.readAccounts().map((x) => x.id), [a.id]);
    expect(store.readActive()?.id, a.id);
  });

  test('adding a second account keeps the first and switches active', () async {
    final store = await _store();
    final a = _account('gitlab.com', 1, 'jungwon');
    final b = _account('git.company.com', 1, 'jungwon');

    await store.add(a);
    await store.add(b);

    // Same user id on two instances: two distinct accounts.
    expect(store.readAccounts().map((x) => x.id).toSet(), {a.id, b.id});
    expect(store.readActive()?.id, b.id);
  });

  test('re-adding an existing account does not duplicate it', () async {
    final store = await _store();
    final a = _account('gitlab.com', 1, 'jungwon');
    await store.add(a);
    await store.add(a);
    expect(store.readAccounts(), hasLength(1));
  });

  test('setActive switches without changing the list', () async {
    final store = await _store();
    final a = _account('gitlab.com', 1, 'a');
    final b = _account('gitlab.com', 2, 'b');
    await store.add(a);
    await store.add(b);

    await store.setActive(a);

    expect(store.readActive()?.id, a.id);
    expect(store.readAccounts(), hasLength(2));
  });

  test('removing the active account falls back to another', () async {
    final store = await _store();
    final a = _account('gitlab.com', 1, 'a');
    final b = _account('gitlab.com', 2, 'b');
    await store.add(a);
    await store.add(b); // b active

    await store.remove(b);

    expect(store.readAccounts().map((x) => x.id), [a.id]);
    expect(store.readActive()?.id, a.id);
  });

  test('removing the last account signs out', () async {
    final store = await _store();
    final a = _account('gitlab.com', 1, 'a');
    await store.add(a);

    await store.remove(a);

    expect(store.readAccounts(), isEmpty);
    expect(store.readActive(), isNull);
  });
}
