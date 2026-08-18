import 'package:flutter/widgets.dart';

/// Which layout a given width gets.
enum LayoutSize {
  /// Bottom navigation, one pane, push navigation.
  mobile,

  /// Navigation rail, two panes.
  tablet,

  /// Navigation rail, multiple panes, command palette, split diff.
  desktop;

  bool get isMobile => this == LayoutSize.mobile;
  bool get isDesktop => this == LayoutSize.desktop;

  /// True once there is room for more than one pane.
  bool get isWide => this != LayoutSize.mobile;
}

/// Width thresholds.
///
/// Layout is chosen by width, never by `Platform.isX`. A desktop window
/// dragged narrow has to become the mobile layout, and a tablet is not a
/// phone; keying off the operating system gets both wrong.
abstract final class LabFoxBreakpoints {
  static const double tablet = 600;
  static const double desktop = 1000;

  static LayoutSize of(double width) {
    if (width >= desktop) {
      return LayoutSize.desktop;
    }
    if (width >= tablet) {
      return LayoutSize.tablet;
    }
    return LayoutSize.mobile;
  }

  /// Reads the layout size from the nearest [MediaQuery].
  static LayoutSize ofContext(BuildContext context) =>
      of(MediaQuery.sizeOf(context).width);
}
