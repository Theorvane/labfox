import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';

/// An app-bar action that copies an item's web link to the clipboard — the
/// share affordance GitHub Mobile puts on a detail screen, using the platform
/// clipboard so it needs no extra dependency. Renders nothing without a [url].
class CopyLinkButton extends StatelessWidget {
  const CopyLinkButton({required this.url, super.key});

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
      tooltip: l10n.copyLink,
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: link));
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.linkCopied)));
        }
      },
    );
  }
}
