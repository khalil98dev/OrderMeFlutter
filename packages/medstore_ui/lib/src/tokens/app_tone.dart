import 'package:flutter/cupertino.dart';

import 'app_colors.dart';

/// The meaning of a colored element. Components take a tone, never a raw color, so the same
/// meaning always looks the same (a "ready" badge, a "paid" metric and a success toast match).
enum AppTone {
  /// No particular meaning: grey.
  neutral,

  /// Emphasis or "selected": Apple's blue.
  accent,

  /// Done, paid, delivered: green.
  success,

  /// Needs attention soon (pending, due): orange.
  warning,

  /// Failed, overdue, destructive: red.
  danger,

  /// Informational: indigo.
  info,
}

/// The two colors of a tone: [foreground] for text and icons, [background] for the tinted fill behind them.
final class ToneColors {
  const ToneColors(this.foreground, this.background);

  final Color foreground;
  final Color background;
}

extension AppToneColors on AppTone {
  ToneColors resolve(BuildContext context) {
    final (foreground, background) = switch (this) {
      AppTone.neutral => (AppColors.textSecondary, AppColors.neutralTint),
      AppTone.accent => (AppColors.accent, AppColors.accentTint),
      AppTone.success => (AppColors.signal, AppColors.signalTint),
      AppTone.warning => (AppColors.warning, AppColors.warningTint),
      AppTone.danger => (AppColors.destructive, AppColors.destructiveTint),
      AppTone.info => (AppColors.info, AppColors.infoTint),
    };
    return ToneColors(foreground.resolveFrom(context), background.resolveFrom(context));
  }
}
