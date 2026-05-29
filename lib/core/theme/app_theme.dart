import 'package:flutter/material.dart';

import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';
import 'neu_colors.dart';

/// Executive Neumorphism Theme — Material 3 ThemeData
///
/// Centralized theme definition for the entire application.
/// Provides both Light and Dark themes.
class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────
  // Light Theme
  // ─────────────────────────────────────────────

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: AppTypography.fontFamilyBody,

        // Color Scheme
        colorScheme: const ColorScheme.light(
          primary: NeuColors.navyDeep,
          onPrimary: NeuColors.textOnDark,
          primaryContainer: NeuColors.navyMid,
          onPrimaryContainer: NeuColors.textOnDark,
          secondary: NeuColors.goldDark,
          onSecondary: NeuColors.textOnDark,
          secondaryContainer: NeuColors.goldLight,
          onSecondaryContainer: NeuColors.textPrimary,
          surface: NeuColors.bgColor,
          onSurface: NeuColors.textPrimary,
          onSurfaceVariant: NeuColors.textSecondary,
          error: NeuColors.danger,
          onError: NeuColors.textOnDark,
          outline: NeuColors.border,
          outlineVariant: NeuColors.divider,
        ),

        // Scaffold
        scaffoldBackgroundColor: NeuColors.bgColor,

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: NeuColors.bgColor,
          foregroundColor: NeuColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTypography.h3,
          iconTheme: IconThemeData(
            color: NeuColors.navyDeep,
            size: 24,
          ),
        ),

        // Bottom Navigation
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: NeuColors.bgColor,
          selectedItemColor: NeuColors.navyDeep,
          unselectedItemColor: NeuColors.textHint,
          selectedLabelStyle: AppTypography.navLabel,
          unselectedLabelStyle: AppTypography.navLabel,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // Card
        cardTheme: CardThemeData(
          color: NeuColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
        ),

        // Elevated Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: NeuColors.navyDeep,
            foregroundColor: NeuColors.textOnDark,
            textStyle: AppTypography.button,
            padding: AppSpacing.button,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),

        // Text Button
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: NeuColors.navyDeep,
            textStyle: AppTypography.button.copyWith(
              color: NeuColors.navyDeep,
            ),
            padding: AppSpacing.button,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
          ),
        ),

        // Outlined Button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: NeuColors.navyDeep,
            side: const BorderSide(color: NeuColors.navyDeep, width: 1.5),
            textStyle: AppTypography.button.copyWith(
              color: NeuColors.navyDeep,
            ),
            padding: AppSpacing.button,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),

        // Input Decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          contentPadding: AppSpacing.input,
          border: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(
              color: NeuColors.navyDeep,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(
              color: NeuColors.danger,
              width: 1.5,
            ),
          ),
          labelStyle: AppTypography.label,
          hintStyle: AppTypography.body.copyWith(
            color: NeuColors.textHint,
          ),
          errorStyle: AppTypography.caption.copyWith(
            color: NeuColors.danger,
          ),
          floatingLabelStyle: AppTypography.label.copyWith(
            color: NeuColors.navyDeep,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Floating Action Button
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: NeuColors.bgColor,
          foregroundColor: NeuColors.navyDeep,
          elevation: 0,
          shape: CircleBorder(),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: NeuColors.divider,
          thickness: 1,
          space: 0,
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: NeuColors.bgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.dialog,
          ),
          titleTextStyle: AppTypography.h3,
          contentTextStyle: AppTypography.body,
        ),

        // Bottom Sheet
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: NeuColors.bgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.bottomSheet,
          ),
        ),

        // Chip
        chipTheme: ChipThemeData(
          backgroundColor: NeuColors.surface,
          labelStyle: AppTypography.caption,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.chip,
          ),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
        ),

        // Snackbar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: NeuColors.navyDeep,
          contentTextStyle: AppTypography.body.copyWith(
            color: NeuColors.textOnDark,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.chip,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

  // ─────────────────────────────────────────────
  // Dark Theme
  // ─────────────────────────────────────────────

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: AppTypography.fontFamilyBody,

        colorScheme: const ColorScheme.dark(
          primary: NeuColors.navyLight,
          onPrimary: NeuColors.textOnDark,
          primaryContainer: NeuColors.navyDeep,
          onPrimaryContainer: NeuColors.textOnDark,
          secondary: NeuColors.goldAccent,
          onSecondary: NeuColors.textPrimary,
          secondaryContainer: NeuColors.goldDark,
          onSecondaryContainer: NeuColors.textOnDark,
          surface: NeuColors.bgColorDark,
          onSurface: NeuColors.textPrimaryDark,
          onSurfaceVariant: NeuColors.textSecondaryDark,
          error: NeuColors.danger,
          onError: NeuColors.textOnDark,
          outline: NeuColors.borderDark,
          outlineVariant: NeuColors.dividerDark,
        ),

        scaffoldBackgroundColor: NeuColors.bgColorDark,

        appBarTheme: AppBarTheme(
          backgroundColor: NeuColors.bgColorDark,
          foregroundColor: NeuColors.textPrimaryDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTypography.h3Dark,
          iconTheme: const IconThemeData(
            color: NeuColors.goldAccent,
            size: 24,
          ),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: NeuColors.bgColorDark,
          selectedItemColor: NeuColors.goldAccent,
          unselectedItemColor: NeuColors.textHintDark,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        cardTheme: CardThemeData(
          color: NeuColors.surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: NeuColors.navyDeep,
            foregroundColor: NeuColors.textOnDark,
            textStyle: AppTypography.button,
            padding: AppSpacing.button,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: NeuColors.goldAccent,
            textStyle: AppTypography.button.copyWith(
              color: NeuColors.goldAccent,
            ),
            padding: AppSpacing.button,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: NeuColors.textPrimaryDark,
            side: const BorderSide(color: NeuColors.borderDark, width: 1.5),
            textStyle: AppTypography.button.copyWith(
              color: NeuColors.textPrimaryDark,
            ),
            padding: AppSpacing.button,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          contentPadding: AppSpacing.input,
          border: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(
              color: NeuColors.goldAccent,
              width: 2,
            ),
          ),
          labelStyle: AppTypography.labelDark,
          hintStyle: AppTypography.bodyDark.copyWith(
            color: NeuColors.textHintDark,
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: NeuColors.bgColorDark,
          foregroundColor: NeuColors.goldAccent,
          elevation: 0,
          shape: CircleBorder(),
        ),

        dividerTheme: const DividerThemeData(
          color: NeuColors.dividerDark,
          thickness: 1,
          space: 0,
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: NeuColors.bgColorDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.dialog,
          ),
          titleTextStyle: AppTypography.h3Dark,
          contentTextStyle: AppTypography.bodyDark,
        ),

        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: NeuColors.bgColorDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.bottomSheet,
          ),
        ),
      );
}
