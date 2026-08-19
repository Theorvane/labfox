import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// A PKCE (RFC 7636) verifier / challenge pair for the OAuth authorization
/// code flow.
///
/// The verifier is a high-entropy secret kept on the device; the challenge is
/// its S256 hash, sent in the authorization request. Because the server only
/// ever sees the challenge, a public client can complete the exchange without
/// a client secret.
class Pkce {
  const Pkce({required this.verifier, required this.challenge});

  final String verifier;
  final String challenge;

  /// The unreserved character set allowed in a code verifier (RFC 7636 §4.1).
  static const _unreserved =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  /// Generates a fresh verifier (96 characters, well within the 43–128 range)
  /// and its S256 challenge. Pass a `Random.secure()` in production; the
  /// parameter exists so tests can seed it.
  factory Pkce.generate({Random? random}) {
    final rng = random ?? Random.secure();
    final verifier = List.generate(
      96,
      (_) => _unreserved[rng.nextInt(_unreserved.length)],
    ).join();
    return Pkce(verifier: verifier, challenge: challengeFor(verifier));
  }

  /// The S256 challenge for a verifier: base64url(sha256(verifier)) with no
  /// padding.
  static String challengeFor(String verifier) {
    final digest = sha256.convert(ascii.encode(verifier));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }
}
