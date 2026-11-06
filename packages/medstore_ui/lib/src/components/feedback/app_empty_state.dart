import 'package:flutter/cupertino.dart';

import '../../tokens/app_colors.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_tone.dart';
import '../../tokens/app_typography.dart';

/// A centered icon, title, message and optional action: an empty list, a screen still to build, an error.
///
/// ```dart
/// AppEmptyState(
///   icon: AppIcons.cart,
///   title: strings.noOrdersTitle,
///   message: strings.noOrdersMessage,
///   action: AppButton(label: strings.newOrder, onPressed: newOrder),
/// )
/// ```
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.tone = AppTone.brand,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = tone.resolve(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Icon(icon, size: 32, color: colors.foreground),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.title3.copyWith(color: AppColors.textPrimary.resolveFrom(context)),
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.textSecondary.resolveFrom(context),
                  ),
                ),
              ],
              if (action != null) ...[const SizedBox(height: AppSpacing.lg), action!],
            ],
          ),
        ),
      ),
    );
  }
}
