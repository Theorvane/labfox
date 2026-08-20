import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens an external link in the system browser.
///
/// One seam for every outbound link (README links, the company pages), so
/// tests can record instead of launching and a future in-app browser swaps in
/// at one place. Only http(s) is ever launched.
final linkOpenerProvider = Provider<Future<void> Function(Uri)>((ref) {
  return (uri) async {
    if (!(uri.isScheme('http') || uri.isScheme('https'))) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  };
});
