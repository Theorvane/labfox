import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/storage/local_projects_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Project _project(int id, String name) =>
    Project(id: id, name: name, pathWithNamespace: 'g/$name');

Future<LocalProjectsStore> _store() async {
  SharedPreferences.setMockInitialValues({});
  return LocalProjectsStore(await SharedPreferences.getInstance());
}

void main() {
  group('recents', () {
    test('starts empty', () async {
      final store = await _store();
      expect(store.readRecents('acct'), isEmpty);
    });

    test('records newest first and de-duplicates by id', () async {
      final store = await _store();

      await store.recordRecent('acct', _project(1, 'a'));
      await store.recordRecent('acct', _project(2, 'b'));
      await store.recordRecent('acct', _project(1, 'a'));

      expect(store.readRecents('acct').map((p) => p.id), [1, 2]);
    });

    test('caps the list at ten, dropping the oldest', () async {
      final store = await _store();
      for (var i = 1; i <= 12; i++) {
        await store.recordRecent('acct', _project(i, 'p$i'));
      }

      final ids = store.readRecents('acct').map((p) => p.id).toList();
      expect(ids.length, 10);
      expect(ids.first, 12);
      expect(ids.contains(1), isFalse);
      expect(ids.contains(2), isFalse);
    });

    test('keeps accounts separate', () async {
      final store = await _store();

      await store.recordRecent('acctA', _project(1, 'a'));
      await store.recordRecent('acctB', _project(2, 'b'));

      expect(store.readRecents('acctA').map((p) => p.id), [1]);
      expect(store.readRecents('acctB').map((p) => p.id), [2]);
    });
  });

  group('favorites', () {
    test('toggles a project on and off', () async {
      final store = await _store();
      final p = _project(1, 'a');

      expect(store.isFavorite('acct', 1), isFalse);

      await store.toggleFavorite('acct', p);
      expect(store.isFavorite('acct', 1), isTrue);
      expect(store.readFavorites('acct').map((x) => x.id), [1]);

      await store.toggleFavorite('acct', p);
      expect(store.isFavorite('acct', 1), isFalse);
      expect(store.readFavorites('acct'), isEmpty);
    });

    test('keeps accounts separate', () async {
      final store = await _store();

      await store.toggleFavorite('acctA', _project(1, 'a'));

      expect(store.isFavorite('acctA', 1), isTrue);
      expect(store.isFavorite('acctB', 1), isFalse);
    });
  });
}
