import 'package:flutter/cupertino.dart';

import '../../tokens/app_colors.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_typography.dart';

/// A setting that is on or off, with a sentence explaining it: "Settle automatically".
///
/// ```dart
/// AppSwitchRow(
///   label: strings.autoSettle,
///   description: strings.autoSettleHint,
///   value: settings.autoSettle,
///   onChanged: (value) => setState(() => autoSettle = value),
/// )
/// ```
///
/// A null [onChanged] shows the switch disabled. The row is read as one switch by screen readers.
class AppSwitchRow extends StatelessWidget {
  const AppSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
  });

  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    return MergeSemantics(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.body.copyWith(color: AppColors.textPrimary.resolveFrom(context)),
                ),
                if (description != null)
                  Text(
                    description,
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.textSecondary.resolveFrom(context),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.accent.resolveFrom(context),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
