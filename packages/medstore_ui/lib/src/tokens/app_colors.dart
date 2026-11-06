import 'package:flutter/cupertino.dart';

/// MedStore colors, on Apple's palette: calm neutral surfaces, Apple's system blue for everything you
/// can press or select, and Apple's system colors for meaning (green done, orange pending, red
/// destructive) and for the sidebar's icon tiles.
///
/// Every token is a [CupertinoDynamicColor]: one constant that carries its light and dark value.
/// `CupertinoThemeData` resolves them by itself; in a widget use `AppColors.x.resolveFrom(context)`.
///
/// Restraint (60-30-10): neutrals carry the screen, blue marks actions and selection, the other colors
/// only carry a meaning. The garnet of the logo is identity, not interface: it stays in the logo.
abstract final class AppColors {
  // ── Accent: Apple's system blue ──────────────────────────────────────────
  /// Buttons, links, the selected sidebar entry and tab, switches, focus.
  static const accent = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF007AFF),
    darkColor: Color(0xFF0A84FF),
  );

  /// The far end of an accent gradient (Apple's indigo), for the few hero surfaces.
  static const accentDeep = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF5856D6),
    darkColor: Color(0xFF5E5CE6),
  );

  /// Tinted fill behind accent content (tinted button, unread row).
  static const accentTint = CupertinoDynamicColor.withBrightness(
    color: Color(0x1A007AFF),
    darkColor: Color(0x330A84FF),
  );

  // ── Brand: garnet, from the logo ─────────────────────────────────────────
  /// The logo's gem. Identity only (the logo, the app icon): never a button or a selection.
  static const brand = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFC4143F),
    darkColor: Color(0xFFF0506F),
  );

  /// Silver of the logo's rim, for quiet chrome.
  static const silver = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFB8BCC6),
    darkColor: Color(0xFF5A6070),
  );

  // ── Semantic ─────────────────────────────────────────────────────────────
  /// "This is done": paid, delivered, ready. Apple's green, one step darker in light mode so green
  /// *text* stays readable on white (WCAG AA).
  static const signal = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF248A3D),
    darkColor: Color(0xFF30D158),
  );
  static const signalTint = CupertinoDynamicColor.withBrightness(
    color: Color(0x1A34C759),
    darkColor: Color(0x2630D158),
  );

  /// Darker than iOS orange in light mode so warning *text* stays readable on its tint (WCAG AA).
  static const warning = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFB25F00),
    darkColor: Color(0xFFFF9F0A),
  );
  static const warningTint = CupertinoDynamicColor.withBrightness(
    color: Color(0x1AFF9500),
    darkColor: Color(0x26FF9F0A),
  );
  static const destructive = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFF3B30),
    darkColor: Color(0xFFFF453A),
  );
  static const destructiveTint = CupertinoDynamicColor.withBrightness(
    color: Color(0x1AFF3B30),
    darkColor: Color(0x26FF453A),
  );
  static const info = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF5856D6),
    darkColor: Color(0xFF5E5CE6),
  );
  static const infoTint = CupertinoDynamicColor.withBrightness(
    color: Color(0x1A5856D6),
    darkColor: Color(0x265E5CE6),
  );

  /// Grey fill for neutral badges and the skeleton placeholders.
  static const neutralTint = CupertinoDynamicColor.withBrightness(
    color: Color(0x14787880),
    darkColor: Color(0x29787880),
  );

  // ── Surfaces ─────────────────────────────────────────────────────────────
  /// Page background, under grouped content.
  static const canvas = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF5F6F8),
    darkColor: Color(0xFF0B0B0E),
  );

  /// Cards, rows, fields.
  static const surface = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFFFFF),
    darkColor: Color(0xFF17181C),
  );

  /// Nested surfaces, dialogs, popovers.
  static const surfaceRaised = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF9FAFB),
    darkColor: Color(0xFF222328),
  );

  /// Desktop sidebar.
  static const sidebar = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFFFFF),
    darkColor: Color(0xFF111215),
  );

  /// Translucent navigation and tab bars (blurred behind).
  static const bar = CupertinoDynamicColor.withBrightness(
    color: Color(0xE6F9F9FB),
    darkColor: Color(0xE61C1C1E),
  );

  // ── Text ─────────────────────────────────────────────────────────────────
  static const textPrimary = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF12131A),
    darkColor: Color(0xFFF2F4F8),
  );
  static const textSecondary = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF5D6472),
    darkColor: Color(0xFFA3A9B6),
  );
  static const textTertiary = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF98A0AD),
    darkColor: Color(0xFF6B7280),
  );
  static const onBrand = Color(0xFFFFFFFF);

  // ── Lines and states ─────────────────────────────────────────────────────
  static const separator = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFEAECF0),
    darkColor: Color(0xFF2A2C33),
  );
  static const border = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFE4E7EC),
    darkColor: Color(0xFF2E3038),
  );
  static const hover = CupertinoDynamicColor.withBrightness(
    color: Color(0x0A000000),
    darkColor: Color(0x12FFFFFF),
  );
}
