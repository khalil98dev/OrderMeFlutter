import 'package:flutter/cupertino.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// The single Cupertino theme. Brightness is not fixed: dynamic colors follow the system's
/// light/dark setting, so one theme serves both.
///
/// Every text style comes from [AppTypography], so system widgets (text fields, navigation bars,
/// tab bars, dialogs) use Inter / IBM Plex Sans Arabic and the active scale (iPhone or Mac).
abstract final class AppTheme {
  static CupertinoThemeData get cupertino {
    TextStyle base(TextStyle style, {Color color = AppColors.textPrimary}) =>
        style.copyWith(inherit: false, color: color, decoration: TextDecoration.none);
    return CupertinoThemeData(
      primaryColor: AppColors.accent,
      primaryContrastingColor: AppColors.onBrand,
      scaffoldBackgroundColor: AppColors.canvas,
      barBackgroundColor: AppColors.bar,
      textTheme: CupertinoTextThemeData(
        primaryColor: AppColors.accent,
        textStyle: base(AppTypography.body),
        navTitleTextStyle: base(AppTypography.headline),
        navLargeTitleTextStyle: base(AppTypography.largeTitle),
        actionTextStyle: base(
          AppTypography.body.copyWith(fontWeight: FontWeight.w500),
          color: AppColors.accent,
        ),
        tabLabelTextStyle: base(
          AppTypography.caption2.copyWith(fontWeight: FontWeight.w600),
        ).copyWith(fontSize: 10, color: null),
      ),
    );
  }

  /// Body text for places outside a Cupertino page (rare).
  static TextStyle get body => AppTypography.body;
}
