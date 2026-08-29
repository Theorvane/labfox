import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ads_providers.dart';

/// The shell's banner slot: the LevelPlay banner for the free tier, nothing
/// at all for subscribers and free desktop builds.
class AdBanner extends ConsumerWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(adsEnabledProvider)) {
      return const SizedBox.shrink();
    }
    final builder = ref.watch(bannerViewBuilderProvider);
    return SafeArea(top: false, child: Center(child: builder(context)));
  }
}
