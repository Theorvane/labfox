import 'unified_diff.dart';

/// The change to one file in a commit or merge request.
///
/// Holds the file's paths and status plus its parsed hunks. A file with no
/// textual diff (a binary asset) has empty hunks and reports [isBinary], so the
/// viewer shows a placeholder rather than nothing.
class FileDiff {
  FileDiff({
    required this.oldPath,
    required this.newPath,
    required this.isNew,
    required this.isDeleted,
    required this.isRenamed,
    required String diff,
  }) : hunks = parseUnifiedDiff(diff),
       _hasDiffText = diff.trim().isNotEmpty;

  final String oldPath;
  final String newPath;
  final bool isNew;
  final bool isDeleted;
  final bool isRenamed;
  final List<DiffHunk> hunks;
  final bool _hasDiffText;

  factory FileDiff.fromJson(Map<String, dynamic> json) {
    return FileDiff(
      oldPath: json['old_path'] as String? ?? '',
      newPath: json['new_path'] as String? ?? '',
      isNew: json['new_file'] as bool? ?? false,
      isDeleted: json['deleted_file'] as bool? ?? false,
      isRenamed: json['renamed_file'] as bool? ?? false,
      diff: json['diff'] as String? ?? '',
    );
  }

  /// A binary file has no textual diff. GitLab sends an empty `diff` for these.
  bool get isBinary => !_hasDiffText && !isRenamed;

  /// The path to show in the file header: a rename shows both sides.
  String get displayPath =>
      isRenamed && oldPath != newPath ? '$oldPath → $newPath' : newPath;
}
