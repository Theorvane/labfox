import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where LabFox publishes its own documents.
const labfoxSiteUrl = 'https://www.sloki9637.com';

/// Apple's standard Terms of Use, the EULA LabFox sells under on the App Store.
///
/// An app that uses the standard EULA links this from its product page and its
/// point of purchase; one that uses its own has to file a custom agreement in
/// App Store Connect instead. LabFox uses Apple's.
const appleStandardEulaUrl =
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

/// The Terms of Use for the store this build was installed from.
///
/// Apple's standard EULA governs an App Store purchase and says nothing about
/// one made through Play, so the link follows the platform rather than naming
/// one document everywhere.
final subscriptionTermsUrlProvider = Provider<String>((ref) {
  return Platform.isIOS || Platform.isMacOS
      ? appleStandardEulaUrl
      : '$labfoxSiteUrl/terms';
});

final subscriptionPrivacyUrlProvider = Provider<String>((ref) {
  return '$labfoxSiteUrl/privacy';
});
