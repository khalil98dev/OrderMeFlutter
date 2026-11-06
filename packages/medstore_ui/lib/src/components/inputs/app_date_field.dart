import 'package:flutter/cupertino.dart';

import '../../formatting/date_format.dart';
import '../../l10n/app_strings.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_icons.dart';
import '../buttons/app_button.dart';
import '../feedback/app_dialog.dart';
import 'app_field_box.dart';

/// Picks a day (no time): the start of a period, a debt's due date.
///
/// ```dart
/// AppDateField(label: strings.periodFrom, value: from, onChanged: cubit.setFrom)
/// AppDateField(label: strings.fieldDueDate, value: due, clearable: false, onChanged: setDue)
/// ```
///
/// Shows the day in the user's language. With [clearable] (the default) a small button empties the
/// field and reports `null`.
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.placeholder,
    this.clearable = true,
    this.errorText,
    this.isRequired = false,
    this.firstDate,
    this.lastDate,
  });

  final String label;

  /// The day, at midnight local time. Null: no day chosen.
  final DateTime? value;

  /// Null disables the field.
  final ValueChanged<DateTime?>? onChanged;
  final String? placeholder;
  final bool clearable;
  final String? errorText;
  final bool isRequired;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final value = this.value;
    final onChanged = this.onChanged;

    return AppFieldBox(
      label: label,
      value: value == null ? null : AppDateFormat.day(value, locale),
      placeholder: placeholder ?? strings.choose,
      icon: AppIcons.calendar,
      errorText: errorText,
      isRequired: isRequired,
      onTap: onChanged == null ? null : () => _open(context, onChanged),
      trailing: clearable && value != null && onChanged != null
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size.square(32),
              onPressed: () => onChanged(null),
              child: Icon(
                AppIcons.cancelled,
                size: 18,
                color: AppColors.textTertiary.resolveFrom(context),
                semanticLabel: strings.clear,
              ),
            )
          : null,
    );
  }

  Future<void> _open(BuildContext context, ValueChanged<DateTime?> onChanged) async {
    final strings = AppStrings.of(context);
    final now = DateTime.now();
    var picked = value ?? DateTime(now.year, now.month, now.day);
    final confirmed = await showAppDialog<bool>(
      context,
      builder: (context) => AppDialog(
        title: label,
        width: 380,
        actions: [
          AppButton(
            label: strings.cancel,
            variant: AppButtonVariant.plain,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppButton(label: strings.confirm, onPressed: () => Navigator.of(context).pop(true)),
        ],
        child: SizedBox(
          height: 200,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: picked,
            minimumDate: firstDate,
            maximumDate: lastDate,
            onDateTimeChanged: (date) => picked = DateTime(date.year, date.month, date.day),
          ),
        ),
      ),
    );
    if (confirmed ?? false) onChanged(picked);
  }
}
