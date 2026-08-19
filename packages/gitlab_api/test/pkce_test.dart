import 'dart:math';

import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  group('Pkce', () {
    test('derives the S256 challenge per RFC 7636 test vector', () {
      // RFC 7636 Appendix B.
      const verifier = 'dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk';
      expect(
        Pkce.challengeFor(verifier),
        'E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM',
      );
    });

    test(
      'generates a verifier of a legal length using only unreserved chars',
      () {
        final pkce = Pkce.generate(random: Random(1));

        expect(pkce.verifier.length, inInclusiveRange(43, 128));
        expect(pkce.verifier, matches(RegExp(r'^[A-Za-z0-9\-._~]+$')));
        expect(pkce.challenge, Pkce.challengeFor(pkce.verifier));
      },
    );

    test('produces a different verifier each time', () {
      final a = Pkce.generate(random: Random(1));
      final b = Pkce.generate(random: Random(2));
      expect(a.verifier, isNot(b.verifier));
    });
  });
}
