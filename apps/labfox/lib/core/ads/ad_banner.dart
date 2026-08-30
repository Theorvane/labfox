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
class AdBanner extends ConsumerWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(adsEnabledProvider)) {
      return const SizedBox.shrink();
    }
    final ready = ref.watch(adsInitializerProvider).valueOrNull ?? false;
    if (!ready) {
      return const SizedBox.shrink();
    }
    final builder = ref.watch(bannerViewBuilderProvider);
    return SafeArea(top: false, child: Center(child: builder(context)));
  }
}
