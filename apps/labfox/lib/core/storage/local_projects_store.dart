import 'dart:convert';

import 'package:gitlab_models/gitlab_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists recently opened projects and locally favorited projects.
///
/// These are a convenience layer over local storage, not GitLab state: they
/// hold no secret, and are namespaced by account id so one account's projects
/// never surface under another.
class LocalProjectsStore {
  LocalProjectsStore(this._prefs);

  final SharedPreferences _prefs;

  /// How many recents to keep. Older entries fall off the end.
  static const _recentsLimit = 10;

  String _recentsKey(String accountId) => 'labfox.recents.$accountId';
  String _favoritesKey(String accountId) => 'labfox.favorites.$accountId';

  List<Project> readRecents(String accountId) => _read(_recentsKey(accountId));

  /// Records a project as the most recent, de-duplicating by id and capping the
  /// list so it does not grow without bound.
  Future<void> recordRecent(String accountId, Project project) async {
    final projects = _read(
      _recentsKey(accountId),
    ).where((p) => p.id != project.id).toList()..insert(0, project);
    final capped = projects.take(_recentsLimit).toList(growable: false);
    await _write(_recentsKey(accountId), capped);
  }

  List<Project> readFavorites(String accountId) =>
      _read(_favoritesKey(accountId));

  bool isFavorite(String accountId, int projectId) =>
      _read(_favoritesKey(accountId)).any((p) => p.id == projectId);

  /// Adds the project to favorites, or removes it if already favorited.
  Future<void> toggleFavorite(String accountId, Project project) async {
    final favorites = _read(_favoritesKey(accountId));
    final without = favorites.where((p) => p.id != project.id).toList();
    if (without.length == favorites.length) {
      without.insert(0, project);
    }
    await _write(_favoritesKey(accountId), without);
  }

  List<Project> _read(String key) {
    final raw = _prefs.getStringList(key) ?? const [];
    return raw
        .map((s) => Project.fromJson(json.decode(s) as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> _write(String key, List<Project> projects) {
    final raw = projects
        .map((p) => json.encode(p.toJson()))
        .toList(growable: false);
    return _prefs.setStringList(key, raw);
  }
}
