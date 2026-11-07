import 'package:flutter/cupertino.dart';

import '../../l10n/app_strings.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_icons.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_typography.dart';

/// The title row of a desktop page: a large title, an optional subtitle, and actions on the end side.
///
/// ```dart
/// AppPageHeader(
///   title: strings.navOrders,
///   subtitle: strings.ordersCount(state.total),
///   actions: [AppButton(label: strings.newOrder, icon: AppIcons.add, onPressed: newOrder)],
/// )
/// ```
///
/// A sub-page (a detail opened from a list) passes [onBack]: a back chevron then sits before the title,
/// pointing the reading direction's way back (it flips in Arabic).
///
/// On mobile, use `CupertinoSliverNavigationBar` instead (the large title that shrinks on scroll).
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.onBack,
    this.backLabel,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  /// Shows a back button before the title.
  final VoidCallback? onBack;

  /// What the back button says to a screen reader ("Back"). Defaults to "Back".
  final String? backLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (onBack != null) ...[
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.square(AppSpacing.minTouchTarget),
            onPressed: onBack,
            child: Icon(
              AppIcons.back,
              color: AppColors.accent.resolveFrom(context),
              semanticLabel: backLabel ?? AppStrings.of(context).back,
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  // Smaller than the page's key figures (28–34): the title names the page, the data leads it.
                  style: AppTypography.title2.copyWith(color: AppColors.textPrimary.resolveFrom(context)),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.textSecondary.resolveFrom(context),
                  ),
                ),
            ],
          ),
        ),
        for (final action in actions) ...[const SizedBox(width: AppSpacing.xs), action],
      ],
    );
  }
}
