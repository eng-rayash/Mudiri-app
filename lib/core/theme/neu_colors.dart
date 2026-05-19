import 'package:flutter/material.dart';

/// Executive Neumorphism Design System — Color Tokens
///
/// All colors are centralized here. No hardcoded colors anywhere else.
/// The system supports Light and Dark themes with matching Neumorphism shadows.
class NeuColors {
  NeuColors._();

  // ─────────────────────────────────────────────
  // Light Theme Colors
  // ─────────────────────────────────────────────

  /// Main background — the foundation of Neumorphism
  static const Color bgColor = Color(0xFFE8EDF2);

  /// Dark shadow (bottom-right)
  static const Color shadowDark = Color(0xFFC8CDD8);

  /// Light shadow (top-left)
  static const Color shadowLight = Color(0xFFFFFFFF);

  /// Card/component surface
  static const Color surface = Color(0xFFEEF2F7);

  // ─────────────────────────────────────────────
  // Dark Theme Colors
  // ─────────────────────────────────────────────

  /// Dark theme background
  static const Color bgColorDark = Color(0xFF1E2530);

  /// Dark theme dark shadow
  static const Color shadowDarkDark = Color(0xFF161C26);

  /// Dark theme light shadow
  static const Color shadowLightDark = Color(0xFF2A3444);

  /// Dark theme surface
  static const Color surfaceDark = Color(0xFF242D3A);

  // ─────────────────────────────────────────────
  // Brand / Executive Colors
  // ─────────────────────────────────────────────

  /// Primary — Deep Navy (executive identity)
  static const Color navyDeep = Color(0xFF1E3A5F);

  /// Secondary navy
  static const Color navyMid = Color(0xFF274C77);

  /// Navy light (for text on dark backgrounds)
  static const Color navyLight = Color(0xFF6096BA);

  /// Gold accent — executive highlight (use sparingly, 1 per screen max)
  static const Color goldAccent = Color(0xFFD4A373);

  /// Gold light variant
  static const Color goldLight = Color(0xFFE8C9A0);

  /// Gold dark variant
  static const Color goldDark = Color(0xFFB8864A);

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
  // Text Colors
  // ─────────────────────────────────────────────

  /// Primary text (headings, important content)
  static const Color textPrimary = Color(0xFF1A2332);

  /// Secondary text (body, descriptions)
  static const Color textSecondary = Color(0xFF5A6A7E);

  /// Hint / placeholder text
  static const Color textHint = Color(0xFF8E9AAD);

  /// Text on dark backgrounds
  static const Color textOnDark = Color(0xFFF5F7FA);

  /// Text on accent backgrounds
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────
  // Dark Theme Text
  // ─────────────────────────────────────────────

  static const Color textPrimaryDark = Color(0xFFE8EDF2);
  static const Color textSecondaryDark = Color(0xFF8E9AAD);
  static const Color textHintDark = Color(0xFF5A6A7E);

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

  static const Color divider = Color(0xFFD8DEE6);
  static const Color dividerDark = Color(0xFF2A3444);
  static const Color border = Color(0xFFD1D9E6);
  static const Color borderDark = Color(0xFF2F3B4A);

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
}
