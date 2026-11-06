import 'package:flutter/cupertino.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// The single Cupertino theme. Brightness is not fixed: dynamic colors follow the system's
/// light/dark setting, so one theme serves both.
///
/// Every text style carries [AppTypography]'s fonts, so system widgets (text fields, navigation bars,
/// tab bars, dialogs) are set in Inter / IBM Plex Sans Arabic like the rest of the app.
abstract final class AppTheme {
  static const CupertinoThemeData cupertino = CupertinoThemeData(
    primaryColor: AppColors.accent,
    primaryContrastingColor: AppColors.onBrand,
    scaffoldBackgroundColor: AppColors.canvas,
    barBackgroundColor: AppColors.bar,
    textTheme: CupertinoTextThemeData(
      primaryColor: AppColors.accent,
      textStyle: TextStyle(
        inherit: false,
        fontFamily: AppTypography.family,
        package: AppTypography.package,
        fontFamilyFallback: AppTypography.fallback,
        fontSize: 17,
        height: 1.4,
        letterSpacing: -0.1,
        color: AppColors.textPrimary,
        decoration: TextDecoration.none,
      ),
      navTitleTextStyle: TextStyle(
        inherit: false,
        fontFamily: AppTypography.family,
        package: AppTypography.package,
        fontFamilyFallback: AppTypography.fallback,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      ),
      navLargeTitleTextStyle: TextStyle(
        inherit: false,
        fontFamily: AppTypography.family,
        package: AppTypography.package,
        fontFamilyFallback: AppTypography.fallback,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: AppColors.textPrimary,
      ),
      actionTextStyle: TextStyle(
        inherit: false,
        fontFamily: AppTypography.family,
        package: AppTypography.package,
        fontFamilyFallback: AppTypography.fallback,
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColors.accent,
      ),
      tabLabelTextStyle: TextStyle(
        inherit: false,
        fontFamily: AppTypography.family,
        package: AppTypography.package,
        fontFamilyFallback: AppTypography.fallback,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  /// Body text for places outside a Cupertino page (rare).
  static const TextStyle body = AppTypography.body;
}
