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
  /// Whether an ad has arrived. The slot takes no space until one has, so a
  /// tier that never fills costs the user nothing.
  ///
  /// One-way on purpose. Banners refresh on their own, and a refresh that
  /// fails leaves the creative already on screen; collapsing then would hide a
  /// live ad and pull the content out from under whoever was reading it. The
  /// jump is worse than the strip it would save.
  var _isVisible = false;

  void _show() {
    if (mounted && !_isVisible) {
      setState(() => _isVisible = true);
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
          child: builder(context, BannerViewCallbacks(onLoaded: _show)),
        ),
      ),
    );
  }
}
