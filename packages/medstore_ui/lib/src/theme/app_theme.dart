import 'package:flutter/cupertino.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// The single Cupertino theme. Brightness is not fixed: dynamic colors follow the system's
/// light/dark setting, so one theme serves both.
abstract final class AppTheme {
  static const CupertinoThemeData cupertino = CupertinoThemeData(
    primaryColor: AppColors.brand,
    primaryContrastingColor: AppColors.onBrand,
    scaffoldBackgroundColor: AppColors.canvas,
    barBackgroundColor: AppColors.bar,
    textTheme: CupertinoTextThemeData(
      primaryColor: AppColors.brand,
      textStyle: TextStyle(
        inherit: false,
        fontSize: 17,
        height: 1.35,
        color: AppColors.textPrimary,
        decoration: TextDecoration.none,
      ),
      navTitleTextStyle: TextStyle(
        inherit: false,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      navLargeTitleTextStyle: TextStyle(
        inherit: false,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      actionTextStyle: TextStyle(inherit: false, fontSize: 17, color: AppColors.brand),
      tabLabelTextStyle: TextStyle(inherit: false, fontSize: 10, fontWeight: FontWeight.w500),
    ),
  );

  /// Body text for places outside a Cupertino page (rare).
  static const TextStyle body = AppTypography.body;
}
