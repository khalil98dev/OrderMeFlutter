import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

/// "From … To …": two day fields side by side, for reports, statements and filtered lists.
class PeriodBar extends StatelessWidget {
  const PeriodBar({
    super.key,
    required this.from,
    required this.to,
    required this.onChanged,
    this.clearable = true,
    this.width = 200,
  });

  final DateTime? from;
  final DateTime? to;

  /// Reports both ends each time one changes.
  final void Function(DateTime? from, DateTime? to) onChanged;
  final bool clearable;
  final double width;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: width,
          child: AppDateField(
            label: strings.periodFrom,
            value: from,
            clearable: clearable,
            onChanged: (value) => onChanged(value, to),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: width,
          child: AppDateField(
            label: strings.periodTo,
            value: to,
            clearable: clearable,
            onChanged: (value) => onChanged(from, value),
          ),
        ),
      ],
    );
  }
}
