import 'package:flutter/material.dart';

/// Brand colours, sampled from the LabFox mark.
abstract final class LabFoxColors {
  /// The navy the mark sits on.
  static const Color navy = Color(0xFF071230);

  /// Primary brand orange.
  static const Color orange = Color(0xFFF54714);

  /// Lighter orange, used for gradients and hover states.
  static const Color orangeLight = Color(0xFFFF8A1F);

  /// Deep red at the tip of the mark.
  static const Color red = Color(0xFFDE2F08);

  /// Pipeline and merge request status colours.
  ///
  /// Status is never signalled by colour alone: every use pairs these with an
  /// icon and a label so the meaning survives colour blindness and greyscale.
  static const Color success = Color(0xFF1F8B4C);
  static const Color failure = Color(0xFFD1293D);
  static const Color running = Color(0xFF1F6FEB);
  static const Color pending = Color(0xFF8B8B8B);
  static const Color warning = Color(0xFFD98B00);
}
