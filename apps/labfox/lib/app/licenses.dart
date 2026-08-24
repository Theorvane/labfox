import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Registers LabFox's own Apache-2.0 license with [LicenseRegistry].
///
/// Flutter auto-collects the LICENSE of every pub dependency, but the app
/// itself is not a pub package, so its license must be added by hand for the
/// in-app license page to present a complete notice (see THIRD_PARTY_NOTICES).
void registerAppLicenses() {
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString('assets/LICENSE');
    yield LicenseEntryWithLineBreaks(const ['LabFox'], text);
  });
}
