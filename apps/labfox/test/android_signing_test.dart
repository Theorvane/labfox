import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the Android release signing config.
///
/// Play rejects an artifact signed with debug keys, and Play Billing does not
/// work in a debug build, so shipping the debug config would break both release
/// and every subscription flow. The failure is silent — the build succeeds and
/// produces an artifact that simply cannot be uploaded — so nothing else in CI
/// would notice.
void main() {
  final gradle = File('android/app/build.gradle.kts');

  test('the release build does not sign with debug keys', () {
    expect(gradle.existsSync(), isTrue, reason: '${gradle.path} is missing');

    final release = _releaseBlock(gradle.readAsStringSync());
    expect(
      release,
      contains('signingConfigs.getByName("release")'),
      reason:
          'The release build type must use the release signing config. See '
          'issue #175.',
    );
    // Debug keys are allowed only as the fallback when no keystore is
    // configured, so what matters is that the choice is conditional rather
    // than that the word never appears.
    if (release.contains('signingConfigs.getByName("debug")')) {
      expect(
        release,
        contains('keystorePropertiesFile.exists()'),
        reason:
            'Debug signing may only be reached when key.properties is absent. '
            'Play rejects a debug-signed artifact, and Play Billing does not '
            'work in one.',
      );
    }
  });

  test('the signing secrets stay out of the repository', () {
    final ignore = File('../../.gitignore').readAsStringSync();

    for (final pattern in const [
      '**/android/key.properties',
      '*.jks',
      '*.keystore',
    ]) {
      expect(
        ignore,
        contains(pattern),
        reason:
            'Dropping "$pattern" from .gitignore would let a keystore or its '
            'passwords be committed. The upload key cannot be rotated once '
            'published, so this is not recoverable.',
      );
    }
  });
}

/// The body of the `release { ... }` build type.
String _releaseBlock(String gradle) {
  final start = gradle.indexOf(RegExp(r'release\s*\{'));
  expect(start, isNot(-1), reason: 'no release build type found');
  var depth = 0;
  for (var i = gradle.indexOf('{', start); i < gradle.length; i++) {
    if (gradle[i] == '{') depth++;
    if (gradle[i] == '}') {
      depth--;
      if (depth == 0) return gradle.substring(start, i + 1);
    }
  }
  fail('unterminated release block');
}
