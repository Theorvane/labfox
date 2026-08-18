import 'package:freezed_annotation/freezed_annotation.dart';

part 'repository_entry.freezed.dart';
part 'repository_entry.g.dart';

/// One node in a repository tree: a folder (`tree`) or a file (`blob`).
@freezed
abstract class RepositoryEntry with _$RepositoryEntry {
  const factory RepositoryEntry({
    required String id,
    required String name,
    required String type,
    required String path,
  }) = _RepositoryEntry;

  const RepositoryEntry._();

  factory RepositoryEntry.fromJson(Map<String, dynamic> json) =>
      _$RepositoryEntryFromJson(json);

  bool get isDirectory => type == 'tree';
  bool get isFile => type == 'blob';

  /// Sort comparator: directories first, then case-insensitive by name.
  ///
  /// GitLab returns tree entries in an order that mixes files and folders;
  /// LabFox groups folders on top so structure reads before contents.
  static int compare(RepositoryEntry a, RepositoryEntry b) {
    if (a.isDirectory != b.isDirectory) {
      return a.isDirectory ? -1 : 1;
    }
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}
