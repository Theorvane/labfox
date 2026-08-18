import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';

/// Picks a layout from the available width.
///
/// One feature, one set of controllers, one behaviour; only the arrangement
/// changes. Splitting a feature per platform would mean a desktop contribution
/// never reaching the mobile app, which is the whole premise of the project.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    this.tablet,
    this.desktop,
    super.key,
  });

  final WidgetBuilder mobile;

  /// Falls back to [mobile] when absent.
  final WidgetBuilder? tablet;

  /// Falls back to [tablet], then [mobile].
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The parent's constraints, not the window size: this widget can sit
        // inside a pane that is narrower than the screen.
        final size = LabFoxBreakpoints.of(constraints.maxWidth);
        final builder = switch (size) {
          LayoutSize.desktop => desktop ?? tablet ?? mobile,
          LayoutSize.tablet => tablet ?? mobile,
          LayoutSize.mobile => mobile,
        };
        return builder(context);
      },
    );
  }
}
