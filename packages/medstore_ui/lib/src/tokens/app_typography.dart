import 'package:flutter/widgets.dart';

/// Apple's text scales and line heights, set in Inter, with IBM Plex Sans Arabic for Arabic: the iPhone
/// scale (body 17) by default, the Mac scale (body 13) once the desktop app calls [useMacScale].
///
/// Both fonts are bundled in this package (`assets/fonts/`), so text looks the same on every platform
/// and offline. Inter has no Arabic glyphs: Flutter draws them with [fallback], whose x-height and
/// weights sit well beside Inter, so mixed French/Arabic lines stay even.
///
/// A style here names its fonts with `package: 'medstore_ui'`, which also prefixes the fallback.
abstract final class AppTypography {
  /// The Latin family, as registered by this package.
  static const family = 'Inter';

  /// Used for every glyph [family] lacks, that is Arabic.
  static const fallback = ['IBMPlexSansArabic'];

  /// The package that bundles [family] and [fallback].
  static const package = 'medstore_ui';

  static var _mac = false;

  /// Whether the Mac scale is in use (the desktop app): smaller text, denser rows and controls.
  static bool get isMac => _mac;

  /// Switches the whole app to Apple's macOS text styles (body 13 instead of 17). Call once in
  /// `main`, before `runApp`; the phone app never calls it.
  static void useMacScale() => _mac = true;

  /// Back to the iPhone scale (tests).
  @visibleForTesting
  static void usePhoneScale() => _mac = false;

  static TextStyle get largeTitle => _mac ? _MacScale.largeTitle : _PhoneScale.largeTitle;
  static TextStyle get title1 => _mac ? _MacScale.title1 : _PhoneScale.title1;
  static TextStyle get title2 => _mac ? _MacScale.title2 : _PhoneScale.title2;
  static TextStyle get title3 => _mac ? _MacScale.title3 : _PhoneScale.title3;
  static TextStyle get headline => _mac ? _MacScale.headline : _PhoneScale.headline;
  static TextStyle get body => _mac ? _MacScale.body : _PhoneScale.body;
  static TextStyle get callout => _mac ? _MacScale.callout : _PhoneScale.callout;
  static TextStyle get subheadline => _mac ? _MacScale.subheadline : _PhoneScale.subheadline;
  static TextStyle get footnote => _mac ? _MacScale.footnote : _PhoneScale.footnote;
  static TextStyle get caption => _mac ? _MacScale.caption : _PhoneScale.caption;
  static TextStyle get caption2 => _mac ? _MacScale.caption2 : _PhoneScale.caption2;

  /// The text of a list row, a table cell, a sidebar entry or a control's label: [subheadline] (15)
  /// on the phone, [body] (13) on the Mac, the size of Apple's Mac lists and tables. Secondary,
  /// greyed text under it stays [subheadline].
  static TextStyle get row => _mac ? _MacScale.body : _PhoneScale.subheadline;

  /// Same-width digits so amounts line up in columns (DZD totals, quantities).
  static TextStyle tabular(TextStyle base) =>
      base.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}

/// iOS text styles (size / leading): body 17 / 22.
abstract final class _PhoneScale {
  static const largeTitle = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.8,
  );
  static const title1 = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.22,
    letterSpacing: -0.6,
  );
  static const title2 = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.27,
    letterSpacing: -0.4,
  );
  static const title3 = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
  );
  static const headline = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.29,
    letterSpacing: -0.2,
  );
  static const body = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.29,
    letterSpacing: -0.1,
  );
  static const callout = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.31,
    letterSpacing: -0.1,
  );
  static const subheadline = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.33,
  );
  static const footnote = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.38,
  );
  static const caption = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.1,
  );
  static const caption2 = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.18,
    letterSpacing: 0.1,
  );
}

/// macOS text styles (size / leading): body 13 / 16, as in Apple's Mac apps.
abstract final class _MacScale {
  static const largeTitle = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.23,
    letterSpacing: -0.6,
  );
  static const title1 = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.18,
    letterSpacing: -0.4,
  );
  static const title2 = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.29,
    letterSpacing: -0.2,
  );
  static const title3 = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: -0.1,
  );
  static const headline = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.23,
    letterSpacing: 0,
  );
  static const body = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.23,
    letterSpacing: 0,
  );
  static const callout = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.25,
    letterSpacing: 0,
  );
  static const subheadline = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.27,
    letterSpacing: 0.1,
  );
  static const footnote = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.1,
  );
  static const caption = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.1,
  );
  static const caption2 = TextStyle(
    fontFamily: AppTypography.family,
    package: AppTypography.package,
    fontFamilyFallback: AppTypography.fallback,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.1,
  );
}
