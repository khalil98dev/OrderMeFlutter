import 'package:flutter/widgets.dart';

/// Apple's text scale, set in Inter, with IBM Plex Sans Arabic for Arabic.
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

  static const largeTitle = TextStyle(
    fontFamily: family,
    package: package,
    fontFamilyFallback: fallback,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.8,
  );
  static const title1 = TextStyle(
    fontFamily: family,
    package: package,
    fontFamilyFallback: fallback,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.22,
    letterSpacing: -0.6,
  );
  static const title2 = TextStyle(
    fontFamily: family,
    package: package,
    fontFamilyFallback: fallback,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.27,
    letterSpacing: -0.4,
  );
  static const title3 = TextStyle(
    fontFamily: family,
    package: package,
    fontFamilyFallback: fallback,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
  );
  static const headline = TextStyle(
    fontFamily: family,
    package: package,
    fontFamilyFallback: fallback,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );
  static const body = TextStyle(
    fontFamily: family,
    package: package,
    fontFamilyFallback: fallback,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: -0.1,
  );
  static const callout = TextStyle(
    fontFamily: family,
    package: package,
    fontFamilyFallback: fallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: -0.1,
  );
  static const subheadline = TextStyle(
    fontFamily: family,
    package: package,
    fontFamilyFallback: fallback,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.38,
  );
  static const footnote = TextStyle(
    fontFamily: family,
    package: package,
    fontFamilyFallback: fallback,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const caption = TextStyle(
    fontFamily: family,
    package: package,
    fontFamilyFallback: fallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
    letterSpacing: 0.1,
  );

  /// Same-width digits so amounts line up in columns (DZD totals, quantities).
  static TextStyle tabular(TextStyle base) =>
      base.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}
