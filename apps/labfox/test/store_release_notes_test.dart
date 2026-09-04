import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the path from the release notes in this repository to the stores.
///
/// The notes are written here so they are reviewed rather than typed into a
/// console field from memory. That only means anything if something carries
/// them the rest of the way: a file nobody reads is a file that drifts from
/// what shipped, and nobody notices until a release says the wrong thing.
///
/// Play accepts release notes with the upload, so the pipeline carries them.
/// The App Store does not — `altool` uploads a build and touches no metadata —
/// so that half stays manual and `RELEASING.md` has to say so.
void main() {
  final playWorkflow = File('../../.github/workflows/android-google-play.yml');
  final script = File('../../scripts/whatsnew.py');
  final releasing = File('../../RELEASING.md');
  final notes = File('../../docs/store/release-notes.md');

  test('the Play upload is given the notes from this repository', () {
    final contents = playWorkflow.readAsStringSync();

    expect(
      contents,
      contains('whatsNewDirectory'),
      reason: 'Without it the upload publishes a release with no notes.',
    );
    expect(contents, contains('scripts/whatsnew.py'));
  });

  test('the script turns the current version into Play notes', () {
    expect(script.existsSync(), isTrue, reason: '${script.path} is missing');

    final version = RegExp(
      r'^version:\s*([^+\s]+)',
      multiLine: true,
    ).firstMatch(File('pubspec.yaml').readAsStringSync())!.group(1)!;
    final out = Directory.systemTemp.createTempSync('whatsnew');
    addTearDown(() => out.deleteSync(recursive: true));

    final result = Process.runSync('python3', [
      'scripts/whatsnew.py',
      '--version',
      version,
      '--out',
      out.path,
    ], workingDirectory: '../..');

    expect(
      result.exitCode,
      0,
      reason: 'The current version must have notes: ${result.stderr}',
    );

    // Play reads one file per locale, named for it.
    for (final locale in ['en-US', 'ko-KR']) {
      final file = File('${out.path}/whatsnew-$locale');
      expect(file.existsSync(), isTrue, reason: 'missing $locale');
      final text = file.readAsStringSync().trim();
      expect(text, isNotEmpty);
      // Play's hard limit. Better to fail the release than to have the store
      // silently truncate a sentence.
      expect(text.length, lessThanOrEqualTo(500));
    }
  });

  test('a version with no notes fails rather than shipping empty ones', () {
    final out = Directory.systemTemp.createTempSync('whatsnew');
    addTearDown(() => out.deleteSync(recursive: true));

    final result = Process.runSync('python3', [
      'scripts/whatsnew.py',
      '--version',
      '99.99.99',
      '--out',
      out.path,
    ], workingDirectory: '../..');

    expect(result.exitCode, isNot(0));
  });

  test('the App Store half is documented as manual', () {
    // altool uploads a build and no metadata, so nothing here can publish the
    // App Store text; saying so is the only honest option.
    expect(releasing.readAsStringSync(), contains("What's New"));
    expect(notes.existsSync(), isTrue);
  });
}
