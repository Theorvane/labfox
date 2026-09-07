import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/core/entitlement/store_entitlement_source.dart';

/// Holds the product id in the code and the product id in the console
/// documentation to the same string.
///
/// App Review rejected a submission because "LabFox subscription was
/// unavailable to purchase". An id that does not exist in the store looks
/// exactly like that from inside the app: the query returns nothing and the
/// screen says there is nothing to sell. The id is also permanent in both
/// consoles, so a rename here can never be answered by a rename there.
void main() {
  test('the documented product id is the one the app queries', () {
    for (final path in [
      '../../docs/store/store-setup.md',
      '../../.agents/docs/billing.md',
    ]) {
      final doc = File(path);
      expect(doc.existsSync(), isTrue, reason: '$path is missing');
      expect(
        doc.readAsStringSync(),
        contains(subscriptionProductId),
        reason:
            '$path documents a different product id than the app asks the '
            'store for, and the store would answer with nothing.',
      );
    }
  });
}
