import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_strings.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_icons.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_typography.dart';

/// A text field with its label above and its error below (top labels read well in both RTL and LTR).
///
/// ```dart
/// AppTextField(label: strings.fieldName, controller: name, isRequired: true, errorText: errors.name)
/// AppTextField(label: strings.fieldDescription, controller: description, maxLines: 4)
/// AppTextField(label: strings.fieldPageCount, controller: pages, digitsOnly: true)
/// ```
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.placeholder,
    this.errorText,
    this.isRequired = false,
    this.obscure = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.digitsOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final String? placeholder;
  final String? errorText;

  /// Adds a "*" after the label.
  final bool isRequired;

  /// A password: hidden, with a show/hide button.
  final bool obscure;
  final bool enabled;
  final bool autofocus;

  /// More than 1 makes a multi-line field (a description).
  final int maxLines;

  /// Only 0-9 can be typed, with the number keyboard on phones (quantities, page counts, prices).
  final bool digitsOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final error = widget.errorText;
    final hasError = error != null && error.isNotEmpty;
    final strings = AppStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.isRequired ? '${widget.label} *' : widget.label,
          style: AppTypography.footnote.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary.resolveFrom(context),
          ),
        ),
        const SizedBox(height: 6),
        CupertinoTextField(
          controller: widget.controller,
          placeholder: widget.placeholder,
          obscureText: _hidden,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          minLines: widget.maxLines > 1 ? 2 : null,
          inputFormatters: widget.digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
          keyboardType: widget.keyboardType ?? (widget.digitsOnly ? TextInputType.number : null),
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: AppTypography.body.copyWith(color: AppColors.textPrimary.resolveFrom(context)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface.resolveFrom(context),
            borderRadius: AppRadii.smRadius,
            border: Border.all(
              color: hasError
                  ? AppColors.destructive.resolveFrom(context)
                  : AppColors.border.resolveFrom(context),
            ),
          ),
          suffix: widget.obscure
              ? CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  minimumSize: const Size.square(AppSpacing.minTouchTarget),
                  onPressed: () => setState(() => _hidden = !_hidden),
                  child: Icon(
                    _hidden ? AppIcons.show : AppIcons.hide,
                    size: 20,
                    color: AppColors.textSecondary.resolveFrom(context),
                    semanticLabel: _hidden ? strings.showPassword : strings.hidePassword,
                  ),
                )
              : null,
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
