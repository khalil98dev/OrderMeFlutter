import 'package:flutter/cupertino.dart';

import '../../tokens/app_colors.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_tone.dart';
import '../../tokens/app_typography.dart';
import '../surfaces/app_card.dart';

/// A dashboard number with its label: "Orders to prepare · 14".
///
/// ```dart
/// AppMetricCard(label: strings.ordersToPrepare, value: '14', icon: AppIcons.cart, tone: AppTone.warning)
/// AppMetricCard(label: strings.collectedThisMonth, value: MoneyFormat.dzd(total, locale), caption: strings.vsLastMonth)
/// ```
class AppMetricCard extends StatelessWidget {
  const AppMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.tone = AppTone.accent,
    this.caption,
    this.onTap,
    this.prominent = false,
  });

  final String label;

  /// Already formatted (use `MoneyFormat` for amounts).
  final String value;
  final IconData? icon;
  final AppTone tone;

  /// A short line under the value ("+12% since last month").
  final String? caption;
  final VoidCallback? onTap;

  /// The one figure the page is about (a wallet's balance, what is owed now): its value is set a
  /// size larger (34 instead of 28), so the eye lands on it first. One per screen.
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final colors = tone.resolve(context);
    final secondary = AppColors.textSecondary.resolveFrom(context);

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subheadline.copyWith(color: secondary),
                ),
              ),
              if (icon != null)
                DecoratedBox(
                  decoration: BoxDecoration(color: colors.background, borderRadius: AppRadii.xsRadius),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: Icon(icon, size: 16, color: colors.foreground),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // One line always: a large amount in a narrow card shrinks to fit instead of wrapping.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              maxLines: 1,
              style: AppTypography.tabular(
                prominent ? AppTypography.largeTitle : AppTypography.title1,
              ).copyWith(color: AppColors.textPrimary.resolveFrom(context)),
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(caption!, style: AppTypography.footnote.copyWith(color: secondary)),
          ],
        ],
      ),
    );
  }
}
