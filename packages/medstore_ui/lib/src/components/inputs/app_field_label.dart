import 'package:flutter/cupertino.dart';

import '../../tokens/app_colors.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_typography.dart';

/// The small bold label above a form control, with a "*" when the field is required.
///
/// ```dart
/// AppFieldLabel(strings.fieldType)
/// AppFieldLabel(strings.fieldTeacher, isRequired: true)
/// ```
///
/// `AppFieldBox`, `AppSelectField` and `AppDateField` draw it themselves; use it directly above a custom
/// control (a segmented control, a list of lines) so every label in a form looks the same.
class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel(this.text, {super.key, this.isRequired = false});

  final String text;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
      child: Text(
        isRequired ? '$text *' : text,
        style: AppTypography.footnote.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary.resolveFrom(context),
        ),
      ),
    );
  }
}
