import 'package:flutter/material.dart';

/// Executive Neumorphism Design System — Color Tokens
///
/// Primary: #22549e (Royal Blue)
/// Secondary: #e0f2aa (Lime Cream)
///
/// All colors are centralized here. No hardcoded colors anywhere else.
/// The system supports Light and Dark themes with matching Neumorphism shadows.
class NeuColors {
  NeuColors._();

  // ─────────────────────────────────────────────
  // Brand / Primary — Royal Blue Family
  // ─────────────────────────────────────────────

  /// Primary — Royal Blue (executive identity)
  static const Color navyDeep = Color(0xFF22549E);

  /// Secondary primary
  static const Color navyMid = Color(0xFF3468B0);

  /// Light primary (for text on dark backgrounds, accents)
  static const Color navyLight = Color(0xFF6B9AD6);

  /// Very light primary (tints, subtle backgrounds)
  static const Color navyTint = Color(0xFFD6E4F5);

  /// Extra dark primary (pressed states)
  static const Color navyDark = Color(0xFF183D75);

  // ─────────────────────────────────────────────
  // Brand / Secondary — Lime Cream Family
  // ─────────────────────────────────────────────

  /// Secondary accent — Lime Cream (use sparingly, 1 per screen max)
  static const Color goldAccent = Color(0xFFCCE88F);

  /// Light variant
  static const Color goldLight = Color(0xFFE0F2AA);

  /// Dark variant (for text/icons on light backgrounds)
  static const Color goldDark = Color(0xFF8DB33A);

  /// Tint variant (very subtle backgrounds)
  static const Color goldTint = Color(0xFFF3FACF);

  // ─────────────────────────────────────────────
  // Light Theme Colors
  // ─────────────────────────────────────────────

  /// Main background — the foundation of Neumorphism
  static const Color bgColor = Color(0xFFECF0F6);

  /// Dark shadow (bottom-right)
  static const Color shadowDark = Color(0xFFCDD2DC);

  /// Light shadow (top-left)
  static const Color shadowLight = Color(0xFFFFFFFF);

  /// Card/component surface
  static const Color surface = Color(0xFFF2F5FA);

  /// Elevated surface (modals, sheets)
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────
  // Dark Theme Colors
  // ─────────────────────────────────────────────

  /// Dark theme background
  static const Color bgColorDark = Color(0xFF141C28);

  /// Dark theme dark shadow
  static const Color shadowDarkDark = Color(0xFF0E1420);

  /// Dark theme light shadow
  static const Color shadowLightDark = Color(0xFF1E2838);

  /// Dark theme surface
  static const Color surfaceDark = Color(0xFF1A2436);

  /// Dark theme elevated surface
  static const Color surfaceElevatedDark = Color(0xFF1F2D42);

  // ─────────────────────────────────────────────
  // Status Colors
  // ─────────────────────────────────────────────

  /// Success / Completed
  static const Color success = Color(0xFF2E8B57);

  /// Warning / Pending / In Progress
  static const Color warning = Color(0xFFF4A261);

  /// Danger / Overdue / Cancelled
  static const Color danger = Color(0xFFD62828);

  /// Info / Scheduled / New
  static const Color info = Color(0xFF3B82F6);

  // ─────────────────────────────────────────────
  // Text Colors — Light Theme
  // ─────────────────────────────────────────────

  /// Primary text (headings, important content)
  static const Color textPrimary = Color(0xFF14202E);

  /// Secondary text (body, descriptions)
  static const Color textSecondary = Color(0xFF506070);

  /// Hint / placeholder text
  static const Color textHint = Color(0xFF8C9AAB);

  /// Text on dark backgrounds
  static const Color textOnDark = Color(0xFFF5F7FA);

  /// Text on accent backgrounds
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────
  // Text Colors — Dark Theme
  // ─────────────────────────────────────────────

  static const Color textPrimaryDark = Color(0xFFE8EDF4);
  static const Color textSecondaryDark = Color(0xFF8E9AAD);
  static const Color textHintDark = Color(0xFF566778);

  // ─────────────────────────────────────────────
  // Priority Colors
  // ─────────────────────────────────────────────

  /// عاجل جدًا — Critical
  static const Color priorityCritical = Color(0xFFD62828);

  /// عالي — High
  static const Color priorityHigh = Color(0xFFF4A261);

  /// متوسط — Medium
  static const Color priorityMedium = Color(0xFF3B82F6);

  /// منخفض — Low
  static const Color priorityLow = Color(0xFF8E9AAD);

  // ─────────────────────────────────────────────
  // Divider & Border
  // ─────────────────────────────────────────────

  static const Color divider = Color(0xFFD8DEE8);
  static const Color dividerDark = Color(0xFF243040);
  static const Color border = Color(0xFFD1D9E6);
  static const Color borderDark = Color(0xFF2A3850);

  // ─────────────────────────────────────────────
  // Helper — Get color by brightness
  // ─────────────────────────────────────────────

  /// Returns the appropriate background color based on brightness
  static Color background(Brightness brightness) =>
      brightness == Brightness.dark ? bgColorDark : bgColor;

  /// Returns the appropriate surface color based on brightness
  static Color surfaceColor(Brightness brightness) =>
      brightness == Brightness.dark ? surfaceDark : surface;

  /// Returns the dark shadow based on brightness
  static Color darkShadow(Brightness brightness) =>
      brightness == Brightness.dark ? shadowDarkDark : shadowDark;

  /// Returns the light shadow based on brightness
  static Color lightShadow(Brightness brightness) =>
      brightness == Brightness.dark ? shadowLightDark : shadowLight;

  /// Returns the appropriate text primary color
  static Color textPrimaryFor(Brightness brightness) =>
      brightness == Brightness.dark ? textPrimaryDark : textPrimary;

  /// Returns the appropriate text secondary color
  static Color textSecondaryFor(Brightness brightness) =>
      brightness == Brightness.dark ? textSecondaryDark : textSecondary;

  /// Returns the appropriate accent color for the theme
  static Color accentFor(Brightness brightness) =>
      brightness == Brightness.dark ? goldAccent : navyDeep;
}
