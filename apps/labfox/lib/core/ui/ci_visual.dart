import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// The glyph and status colour for a CI status, drawn from the theme-aware
/// status tokens so pipeline and job rows read the same as issue and MR rows.
(IconData, StatusColor) ciVisual(CiStatus status, LabFoxStatusColors colors) {
  return switch (status) {
    CiStatus.success => (Icons.check_circle_outline, colors.open),
    CiStatus.failed => (Icons.cancel_outlined, colors.closed),
    CiStatus.running => (Icons.autorenew, colors.running),
    CiStatus.pending => (Icons.schedule, colors.pending),
    CiStatus.canceled => (Icons.block, colors.pending),
    CiStatus.skipped => (Icons.skip_next, colors.pending),
    CiStatus.manual => (Icons.play_circle_outline, colors.pending),
    CiStatus.created => (Icons.fiber_new_outlined, colors.pending),
    CiStatus.other => (Icons.help_outline, colors.pending),
  };
}

/// A human label for a raw CI status string (`success` -> `Success`).
String ciLabel(String status) {
  if (status.isEmpty) {
    return status;
  }
  return status[0].toUpperCase() + status.substring(1);
}
