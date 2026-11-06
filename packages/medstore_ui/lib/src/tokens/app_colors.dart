import 'package:flutter/cupertino.dart';

/// MedStore colors: the garnet of the logo's gem on calm, Apple-style neutral surfaces.
///
/// Every token is a [CupertinoDynamicColor]: one constant that carries its light and dark value.
/// `CupertinoThemeData` resolves them by itself; in a widget use `AppColors.x.resolveFrom(context)`.
///
/// Restraint (60-30-10): neutrals carry the screen, garnet marks actions and selection, teal is spent
/// only on "done / paid / delivered". Destructive red is iOS system red, brighter and more orange than
/// the garnet, so "delete" never reads as "brand".
abstract final class AppColors {
  // ── Brand: garnet, from the logo ─────────────────────────────────────────
  static const brand = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFC4143F),
    darkColor: Color(0xFFF0506F),
  );
  static const brandDeep = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF8E0C2C),
    darkColor: Color(0xFFC4143F),
  );

  /// Tinted fill behind brand content (selected row, tinted button).
  static const brandTint = CupertinoDynamicColor.withBrightness(
    color: Color(0x1AC4143F),
    darkColor: Color(0x33F0506F),
  );

  /// Silver of the logo's rim, for quiet chrome.
  static const silver = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFB8BCC6),
    darkColor: Color(0xFF5A6070),
  );

  // ── Semantic ─────────────────────────────────────────────────────────────
  /// "This is done": paid, delivered, ready.
  static const signal = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF0D9488),
    darkColor: Color(0xFF2DD4BF),
  );
  static const signalTint = CupertinoDynamicColor.withBrightness(
    color: Color(0x1A0D9488),
    darkColor: Color(0x262DD4BF),
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
