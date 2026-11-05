import 'package:flutter/widgets.dart';

/// Apple's text scale. No font family is set: each platform's system font is used (SF on Apple,
/// Segoe UI on Windows, Roboto/Noto on Android), and all of them carry Arabic and French glyphs, so
/// nothing is downloaded or bundled.
abstract final class AppTypography {
  static const largeTitle = TextStyle(fontSize: 34, fontWeight: FontWeight.w700, height: 1.2);
  static const title1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.22);
  static const title2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.27);
  static const title3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3);
  static const headline = TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.3);
  static const body = TextStyle(fontSize: 17, fontWeight: FontWeight.w400, height: 1.35);
  static const callout = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.35);
  static const subheadline = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.33);
  static const footnote = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.38);
  static const caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.33);

  /// Same-width digits so amounts line up in columns (DZD totals, quantities).
  static TextStyle tabular(TextStyle base) =>
      base.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}
