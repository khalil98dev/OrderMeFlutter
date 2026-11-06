import 'package:flutter/cupertino.dart';

import '../../tokens/app_colors.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_typography.dart';

/// A tick box: a filter ("Include voided") or one cell of a grid of choices (a role's permissions).
///
/// ```dart
/// AppCheckbox(label: strings.includeVoided, value: includeVoided, onChanged: cubit.includeVoided)
/// AppCheckbox(label: 'Order · Read', showLabel: false, value: granted, onChanged: toggle) // a grid cell
/// ```
///
/// [label] is required even when hidden ([showLabel] false): a screen reader must know what the box is
/// for. A null [onChanged] shows it disabled.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.showLabel = true,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final box = CupertinoCheckbox(
      value: value,
      activeColor: AppColors.accent.resolveFrom(context),
      semanticLabel: label,
      onChanged: onChanged == null ? null : (checked) => onChanged(checked ?? false),
    );
    if (!showLabel) return box;

    final textColor = onChanged == null ? AppColors.textTertiary : AppColors.textPrimary;
    return MergeSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged(!value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            box,
            const SizedBox(width: AppSpacing.xxs),
            Text(label, style: AppTypography.subheadline.copyWith(color: textColor.resolveFrom(context))),
          ],
        ),
      ),
    );
  }
}
