import 'package:flutter/cupertino.dart';

import '../../tokens/app_colors.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_typography.dart';

/// A label and its value on one line, for the facts of a record: "Due date · 30/11/2026".
///
/// ```dart
/// AppInfoRow(label: strings.fieldPhone, value: teacher.phone)
/// AppInfoRow(label: strings.amountDue, child: AppMoney(invoice.amountDue, tone: AppTone.danger), emphasized: true)
/// ```
///
/// Give [value] for text or [child] for anything else (an amount, a badge). A null [value] shows "—",
/// so a field the user may not read stays visibly empty instead of disappearing.
class AppInfoRow extends StatelessWidget {
  const AppInfoRow({super.key, required this.label, this.value, this.child, this.emphasized = false});

  final String label;
  final String? value;
  final Widget? child;

  /// Bold label, for a total.
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final child = this.child;
    final labelStyle = AppTypography.subheadline.copyWith(
      color: AppColors.textSecondary.resolveFrom(context),
      fontWeight: emphasized ? FontWeight.w600 : null,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            flex: 2,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child:
                  child ??
                  Text(
                    value ?? '—',
                    textAlign: TextAlign.end,
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.textPrimary.resolveFrom(context),
                      fontWeight: emphasized ? FontWeight.w600 : null,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
