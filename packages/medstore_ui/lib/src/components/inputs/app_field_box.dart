import 'package:flutter/cupertino.dart';

import '../../tokens/app_colors.dart';
import '../../tokens/app_icons.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_typography.dart';
import '../surfaces/pressable.dart';
import 'app_field_label.dart';

/// A tappable box that looks like a text field: a label above, the current value inside, an error below.
///
/// The base of every "pick something" field (`AppSelectField`, `AppDateField`, a teacher picker):
///
/// ```dart
/// AppFieldBox(
///   label: strings.fieldTeacher,
///   value: teacher?.fullName,
///   placeholder: strings.chooseTeacher,
///   icon: AppIcons.person,
///   onTap: pickTeacher,
/// )
/// ```
///
/// A null [onTap] shows the field disabled.
class AppFieldBox extends StatelessWidget {
  const AppFieldBox({
    super.key,
    required this.label,
    required this.onTap,
    this.value,
    this.placeholder,
    this.icon,
    this.errorText,
    this.isRequired = false,
    this.trailing,
  });

  final String label;
  final String? value;

  /// Shown, greyed, while [value] is null.
  final String? placeholder;
  final IconData? icon;
  final String? errorText;
  final bool isRequired;
  final VoidCallback? onTap;

  /// An extra control at the end, inside the box (a "clear" button).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final error = errorText;
    final hasError = error != null && error.isNotEmpty;
    final value = this.value;
    final trailing = this.trailing;
    final enabled = onTap != null;
    final textColor = value == null || !enabled ? AppColors.textTertiary : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFieldLabel(label, isRequired: isRequired),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface.resolveFrom(context),
            borderRadius: AppRadii.smRadius,
            border: Border.all(
              color: hasError
                  ? AppColors.destructive.resolveFrom(context)
                  : AppColors.border.resolveFrom(context),
            ),
          ),
          child: Pressable(
            onTap: onTap,
            borderRadius: AppRadii.smRadius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: AppSpacing.sm, end: AppSpacing.xs),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: AppColors.textSecondary.resolveFrom(context)),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Expanded(
                      child: Text(
                        value ?? placeholder ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body.copyWith(color: textColor.resolveFrom(context)),
                      ),
                    ),
                    ?trailing,
                    Icon(AppIcons.sort, size: 16, color: AppColors.textTertiary.resolveFrom(context)),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            error,
            style: AppTypography.footnote.copyWith(color: AppColors.destructive.resolveFrom(context)),
          ),
        ],
      ],
    );
  }
}
