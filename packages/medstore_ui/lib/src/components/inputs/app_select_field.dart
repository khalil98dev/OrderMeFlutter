import 'package:flutter/cupertino.dart';

import '../../l10n/app_strings.dart';
import 'app_field_box.dart';

/// Picks one value from a list too long for a segmented control: a school level, a payment method,
/// a role, a report grouping.
///
/// ```dart
/// AppSelectField<PaymentTerms>(
///   label: strings.fieldPaymentTerms,
///   options: {for (final t in PaymentTerms.values) t: paymentTermsText(strings, t)},
///   value: terms,
///   onChanged: (value) => setState(() => terms = value),
/// )
/// ```
///
/// Opens an action sheet with every option (the current one in bold). With [allowNone] the sheet also
/// offers [noneLabel] ("All" by default), which reports `null`: a filter's "all", an optional field's
/// "none".
class AppSelectField<T extends Object> extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.placeholder,
    this.errorText,
    this.isRequired = false,
    this.allowNone = false,
    this.noneLabel,
    this.icon,
  });

  final String label;

  /// Every choice and its text, in the order shown.
  final Map<T, String> options;
  final T? value;

  /// Null disables the field.
  final ValueChanged<T?>? onChanged;
  final String? placeholder;
  final String? errorText;
  final bool isRequired;
  final bool allowNone;
  final String? noneLabel;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final value = this.value;
    final onChanged = this.onChanged;
    return AppFieldBox(
      label: label,
      value: value == null ? (allowNone ? noneLabel ?? strings.filterAll : null) : options[value],
      placeholder: placeholder ?? strings.choose,
      errorText: errorText,
      isRequired: isRequired,
      icon: icon,
      onTap: onChanged == null ? null : () => _open(context, onChanged),
    );
  }

  Future<void> _open(BuildContext context, ValueChanged<T?> onChanged) async {
    final strings = AppStrings.of(context);
    final picked = await showCupertinoModalPopup<_Picked<T>>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(label),
        actions: [
          if (allowNone)
            CupertinoActionSheetAction(
              isDefaultAction: value == null,
              onPressed: () => Navigator.of(context).pop(_Picked<T>(null)),
              child: Text(noneLabel ?? strings.filterAll),
            ),
          for (final MapEntry(key: option, value: text) in options.entries)
            CupertinoActionSheetAction(
              isDefaultAction: option == value,
              onPressed: () => Navigator.of(context).pop(_Picked<T>(option)),
              child: Text(text),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.cancel),
        ),
      ),
    );
    if (picked != null) onChanged(picked.value);
  }
}

/// Tells "closed the sheet" (`null`) from "picked the none option" (`_Picked(null)`).
final class _Picked<T> {
  const _Picked(this.value);

  final T? value;
}
