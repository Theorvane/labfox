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
    this.isTooLarge = false,
    this.isCollapsed = false,
  }) : hunks = parseUnifiedDiff(diff),
       _hasDiffText = diff.trim().isNotEmpty;

  final String oldPath;
  final String newPath;
  final bool isNew;
  final bool isDeleted;
  final bool isRenamed;
  final List<DiffHunk> hunks;
  final bool _hasDiffText;

  /// GitLab omitted the diff text because it exceeds the size limit.
  final bool isTooLarge;

  /// GitLab returned the file collapsed, without its diff text.
  final bool isCollapsed;

  factory FileDiff.fromJson(Map<String, dynamic> json) {
    return FileDiff(
      oldPath: json['old_path'] as String? ?? '',
      newPath: json['new_path'] as String? ?? '',
      isNew: json['new_file'] as bool? ?? false,
      isDeleted: json['deleted_file'] as bool? ?? false,
      isRenamed: json['renamed_file'] as bool? ?? false,
      diff: json['diff'] as String? ?? '',
      isTooLarge: json['too_large'] as bool? ?? false,
      isCollapsed: json['collapsed'] as bool? ?? false,
    );
  }

  /// A binary file has no textual diff. GitLab sends an empty `diff` for these,
  /// but it also sends an empty `diff` for a text file it truncated
  /// ([isTooLarge]) or collapsed ([isCollapsed]); those are not binary, so they
  /// are excluded here and surfaced separately by the viewer.
  bool get isBinary =>
      !_hasDiffText && !isRenamed && !isTooLarge && !isCollapsed;

  /// True when there is no diff to render but the file is not binary — GitLab
  /// omitted the text because the diff was too large or collapsed.
  bool get isOmitted => (isTooLarge || isCollapsed) && hunks.isEmpty;

  /// The path to show in the file header: a rename shows both sides.
  String get displayPath =>
      isRenamed && oldPath != newPath ? '$oldPath → $newPath' : newPath;
}
