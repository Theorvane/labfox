import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final releaseWorkflow = File('../../.github/workflows/release.yml');
  final iosWorkflow = File('../../.github/workflows/ios-app-store-connect.yml');
  final androidWorkflow = File(
    '../../.github/workflows/android-google-play.yml',
  );

  test('only the final release job can write repository contents', () {
    final contents = releaseWorkflow.readAsStringSync();

    expect(contents, contains('permissions:\n  contents: read'));
    expect(
      contents,
      matches(
        RegExp(
          r'  release:\n[\s\S]*?    permissions:\n'
          r'      contents: write\n'
          r'      actions: read',
        ),
      ),
    );
  });

  test('release checkouts do not persist credentials', () {
    expect(
      RegExp(
        'persist-credentials: false',
      ).allMatches(releaseWorkflow.readAsStringSync()).length,
      3,
    );
    expect(
      iosWorkflow.readAsStringSync(),
      contains('persist-credentials: false'),
    );
    expect(
      androidWorkflow.readAsStringSync(),
      contains('persist-credentials: false'),
    );
  });
}
