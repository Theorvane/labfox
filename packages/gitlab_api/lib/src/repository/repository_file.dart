import 'dart:convert';
import 'dart:typed_data';

/// The contents of a repository file, decoded as text when it is text.
///
/// A repository holds binary files too — images, fonts, compiled output. Those
/// have no meaningful text form, so [isBinary] is set and [text] stays null
/// rather than handing the UI mojibake to render.
class RepositoryFile {
  const RepositoryFile._({required this.isBinary, this.text});

  final bool isBinary;
  final String? text;

  /// Builds a file from raw bytes, deciding text vs binary.
  ///
  /// A NUL byte in the first chunk is the cheap, reliable signal Git itself
  /// uses to call a blob binary; UTF-8 that fails to decode is treated the same
  /// way.
  factory RepositoryFile.fromBytes(Uint8List bytes) {
    final sample = bytes.length > 8000 ? bytes.sublist(0, 8000) : bytes;
    if (sample.contains(0)) {
      return const RepositoryFile._(isBinary: true);
    }
    try {
      return RepositoryFile._(isBinary: false, text: utf8.decode(bytes));
    } on FormatException {
      return const RepositoryFile._(isBinary: true);
    }
  }
}
