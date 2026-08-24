import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the App Store Connect API-key setup used by altool.
///
/// The upload is the final release step, after the paid macOS runner has
/// already built, archived, and signed the app. A key in an undiscoverable
/// directory therefore wastes the whole run before failing authentication.
void main() {
  final workflow = File('../../.github/workflows/ios-app-store-connect.yml');
  final ciWorkflow = File('../../.github/workflows/ci.yml');
  final podfile = File('ios/Podfile');

  test('altool receives the private-key directory explicitly', () {
    expect(
      workflow.existsSync(),
      isTrue,
      reason: '${workflow.path} is missing',
    );

    final contents = workflow.readAsStringSync();
    expect(
      contents,
      contains(
        'export API_PRIVATE_KEYS_DIR='
        '"\$RUNNER_TEMP/app-store-connect-api-keys"',
      ),
      reason:
          'altool must receive an explicit API_PRIVATE_KEYS_DIR so it can '
          'discover the App Store Connect private key.',
    );
    expect(
      contents,
      contains('"\$API_PRIVATE_KEYS_DIR/AuthKey_\${ASC_KEY_ID}.p8"'),
      reason:
          'The private key filename and directory must match what altool '
          'looks up for --apiKey.',
    );
  });

  test('CocoaPods targets do not inherit the app provisioning profile', () {
    expect(podfile.existsSync(), isTrue, reason: '${podfile.path} is missing');

    expect(
      podfile.readAsStringSync(),
      contains("config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'"),
      reason:
          'Generated framework targets must not inherit the Runner app\'s '
          'manual provisioning profile during an archive.',
    );
  });

  test(
    'archive runner provides the iOS 26 SDK required by App Store Connect',
    () {
      expect(
        workflow.readAsStringSync(),
        contains('runs-on: macos-26'),
        reason:
            'App Store Connect rejects archives built with the iOS 18 SDK from '
            'the macos-15 runner.',
      );
    },
  );

  test('pull requests validate the iOS SDK from the exact head commit', () {
    expect(
      ciWorkflow.existsSync(),
      isTrue,
      reason: '${ciWorkflow.path} is missing',
    );

    final contents = ciWorkflow.readAsStringSync();
    expect(contents, contains('  ios-sdk:\n'));
    expect(contents, contains('    runs-on: macos-26'));
    expect(
      contents,
      contains('ref: \${{ github.event.pull_request.head.sha }}'),
      reason: 'The macOS check must test the PR head, not GitHub\'s merge ref.',
    );
    expect(contents, contains('persist-credentials: false'));
    expect(contents, contains('xcrun --sdk iphoneos --show-sdk-version'));
    expect(contents, contains('flutter build ios --release --no-codesign'));
  });
}
