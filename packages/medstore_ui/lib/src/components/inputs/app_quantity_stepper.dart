import 'package:flutter/cupertino.dart';

import '../../l10n/app_strings.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_icons.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_typography.dart';

/// − 12 + : picks how many copies to print.
///
/// ```dart
/// AppQuantityStepper(value: line.quantity, min: 1, max: 500, onChanged: (q) => cubit.setQuantity(line.id, q))
/// ```
///
/// The buttons turn off at [min] and [max]. Long-pressing is not needed: big quantities are typed in a
/// text field by the screen that needs them.
class AppQuantityStepper extends StatelessWidget {
  const AppQuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max,
    this.step = 1,
  }) : assert(max == null || max >= min, 'max must be at least min');

  final int value;
  final ValueChanged<int>? onChanged;
  final int min;
  final int? max;
  final int step;

  bool get _canDecrease => onChanged != null && value - step >= min;
  bool get _canIncrease => onChanged != null && (max == null || value + step <= max!);

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.neutralTint.resolveFrom(context),
        borderRadius: AppRadii.smRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: AppIcons.remove,
            label: strings.decreaseQuantity,
            onPressed: _canDecrease ? () => onChanged!(value - step) : null,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 40),
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTypography.tabular(
                AppTypography.headline,
              ).copyWith(color: AppColors.textPrimary.resolveFrom(context)),
            ),
          ),
          _StepButton(
            icon: AppIcons.add,
            label: strings.increaseQuantity,
            onPressed: _canIncrease ? () => onChanged!(value + step) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = onPressed == null
        ? AppColors.textTertiary.resolveFrom(context)
        : AppColors.accent.resolveFrom(context);
    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      minimumSize: const Size.square(AppSpacing.minTouchTarget),
      child: Icon(icon, size: 18, color: color, semanticLabel: label),
    );
  }
}
