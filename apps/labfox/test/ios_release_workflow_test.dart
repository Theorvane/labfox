import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the App Store Connect API-key setup used by altool.
///
/// The upload is the final release step, after the paid macOS runner has
/// already built, archived, and signed the app. A key in an undiscoverable
/// directory therefore wastes the whole run before failing authentication.
void main() {
  final workflow = File('../../.github/workflows/ios-app-store-connect.yml');

  test('altool receives the private-key directory explicitly', () {
    expect(workflow.existsSync(), isTrue, reason: '${workflow.path} is missing');

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
      contains(
        '"\$API_PRIVATE_KEYS_DIR/AuthKey_\${ASC_KEY_ID}.p8"',
      ),
      reason:
          'The private key filename and directory must match what altool '
          'looks up for --apiKey.',
    );
  });
}
