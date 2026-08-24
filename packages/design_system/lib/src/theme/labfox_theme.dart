import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/status_colors.dart';

/// Light and dark themes.
///
/// Two committed visual worlds built from one function so a change cannot land
/// in one and be forgotten in the other:
///
/// - **Paper** (light): true white, cool hairlines, ink-black text.
/// - **Graphite** (dark): near-black cool ground, dim slate lines.
///
/// The LabFox orange is a sharp accent used sparingly — the primary action and
/// the active state — never a background wash. Status hues live in
/// [LabFoxStatusColors]; neutrals do the rest of the work.
abstract final class LabFoxTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: LabFoxColors.orange,
          brightness: brightness,
        ).copyWith(
          primary: isDark ? const Color(0xFFFF5A1F) : LabFoxColors.orange,
          onPrimary: isDark ? const Color(0xFF14100D) : Colors.white,
          surface: isDark ? const Color(0xFF080D1A) : const Color(0xFFFAF9F7),
          onSurface: isDark ? const Color(0xFFE7EAF2) : const Color(0xFF101725),
          onSurfaceVariant: isDark
              ? const Color(0xFF96A0B4)
              : const Color(0xFF5A6172),
          surfaceContainerHighest: isDark
              ? const Color(0xFF151C2B)
              : const Color(0xFFF1F0ED),
          surfaceContainerHigh: isDark
              ? const Color(0xFF121828)
              : const Color(0xFFECEBE7),
          surfaceContainer: isDark
              ? const Color(0xFF0E1424)
              : const Color(0xFFF1F0ED),
          outlineVariant: isDark
              ? const Color(0xFF222A3A)
              : const Color(0xFFE5E3DF),
          outline: isDark ? const Color(0xFF313A4C) : const Color(0xFFC3C0BA),
          error: isDark ? const Color(0xFFE0475C) : const Color(0xFF9E1B2C),
          onError: isDark ? const Color(0xFF14100D) : Colors.white,
        );

    final baseText =
        (isDark ? Typography.whiteMountainView : Typography.blackMountainView)
            .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    // Confident, tight headings; the rest of the scale is left to the platform
    // face so the app reads native.
    final textTheme = baseText.copyWith(
      headlineSmall: baseText.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.standard,
      extensions: [isDark ? LabFoxStatusColors.dark : LabFoxStatusColors.light],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 20),
      ),
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: scheme.outlineVariant,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LabFoxRadius.lg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: LabFoxSpacing.sm,
        contentPadding: EdgeInsets.symmetric(horizontal: LabFoxSpacing.md),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, LabFoxSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LabFoxRadius.md),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, LabFoxSpacing.minTouchTarget),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LabFoxRadius.md),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LabFoxRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LabFoxRadius.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LabFoxRadius.md),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
