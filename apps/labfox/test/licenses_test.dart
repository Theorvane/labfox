import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/app/licenses.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(LicenseRegistry.reset);

  test('registers LabFox\'s own Apache-2.0 license', () async {
    registerAppLicenses();

    final entries = await LicenseRegistry.licenses.toList();
    final labfox = entries.where((e) => e.packages.contains('LabFox'));

    expect(labfox, isNotEmpty, reason: 'the app license must be registered');
    final text = labfox.first.paragraphs.map((p) => p.text).join(' ');
    expect(text, contains('Apache License'));
  });
}
