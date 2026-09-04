import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ads_providers.dart';

/// The shell's banner slot: the LevelPlay banner for the free tier, nothing
/// at all for subscribers and free desktop builds.
///
/// The banner view loads as soon as its platform view exists, so it is mounted
/// only once the SDK reports it is up. Mounted earlier, that one load attempt
/// is spent on a call the SDK rejects and the slot stays empty for the whole
/// session.
class AdBanner extends ConsumerStatefulWidget {
  const AdBanner({super.key});

  @override
  ConsumerState<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends ConsumerState<AdBanner> {
  var _isVisible = false;

  void _show() {
    if (mounted && !_isVisible) {
      setState(() => _isVisible = true);
    }
  }

  void _hide() {
    if (mounted && _isVisible) {
      setState(() => _isVisible = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(adsEnabledProvider)) {
      return const SizedBox.shrink();
    }
    final ready = ref.watch(adsInitializerProvider).valueOrNull ?? false;
    if (!ready) {
      return const SizedBox.shrink();
    }
    final builder = ref.watch(bannerViewBuilderProvider);
    return SafeArea(
      top: false,
      child: Offstage(
        offstage: !_isVisible,
        child: Center(
          child: builder(
            context,
            BannerViewCallbacks(onLoaded: _show, onFailed: _hide),
          ),
        ),
      ),
    );
  }
}
