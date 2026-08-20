import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';

/// An app-bar action that opens the system share sheet for an item's web link —
/// the share affordance GitHub Mobile puts on a detail screen. Renders nothing
/// without a [url].
class ShareLinkButton extends StatelessWidget {
  const ShareLinkButton({required this.url, super.key});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final link = url;
    if (link == null || link.isEmpty) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    return IconButton(
      icon: const Icon(Icons.ios_share),
      tooltip: l10n.shareLink,
      onPressed: () =>
          SharePlus.instance.share(ShareParams(uri: Uri.parse(link))),
    );
  }
}
