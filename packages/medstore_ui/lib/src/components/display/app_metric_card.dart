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
  });

  final String label;

  /// Already formatted (use `MoneyFormat` for amounts).
  final String value;
  final IconData? icon;
  final AppTone tone;

  /// A short line under the value ("+12% since last month").
  final String? caption;
  final VoidCallback? onTap;

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
                    padding: const EdgeInsets.all(6),
                    child: Icon(icon, size: 16, color: colors.foreground),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.tabular(
              AppTypography.title1,
            ).copyWith(color: AppColors.textPrimary.resolveFrom(context)),
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
