import 'package:flutter/cupertino.dart';

import '../../formatting/money_format.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_tone.dart';
import '../../tokens/app_typography.dart';

/// An amount in dinars, formatted for the user's language, with digits that line up in columns.
///
/// ```dart
/// AppMoney(order.total)                                   // "12 500 DA"
/// AppMoney(balance, style: AppTypography.title2, tone: AppTone.success)
/// ```
///
/// Amounts are never cut with "…": a wrong-looking number is worse than a wrapped line.
class AppMoney extends StatelessWidget {
  const AppMoney(this.amount, {super.key, this.style, this.tone, this.decimals = 0});

  final num amount;

  /// Defaults to [AppTypography.body].
  final TextStyle? style;

  /// Colors the amount (paid → success, overdue → danger). Null keeps the normal text color.
  final AppTone? tone;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    final color = tone?.resolve(context).foreground ?? AppColors.textPrimary.resolveFrom(context);
    return Text(
      MoneyFormat.dzd(amount, Localizations.localeOf(context), decimals: decimals),
      style: AppTypography.tabular(style ?? AppTypography.body).copyWith(color: color),
    );
  }
}
