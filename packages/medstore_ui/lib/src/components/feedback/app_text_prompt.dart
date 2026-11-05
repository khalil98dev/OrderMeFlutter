import 'package:flutter/cupertino.dart';

import '../../l10n/app_strings.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_typography.dart';
import '../buttons/app_button.dart';
import '../inputs/app_text_field.dart';
import 'app_dialog.dart';

/// Asks for one piece of text before an action: the reason for voiding an invoice, a note for the
/// teacher. Resolves to the trimmed text, or `null` when cancelled.
///
/// ```dart
/// final reason = await showAppTextPrompt(
///   context,
///   title: strings.voidInvoiceTitle,
///   message: strings.voidInvoiceMessage,
///   label: strings.fieldReason,
///   confirmLabel: strings.voidAction,
///   destructive: true,
/// );
/// if (reason != null) await cubit.voidInvoice(reason);
/// ```
///
/// With [isRequired] (the default) the confirm button stays off while the field is empty.
Future<String?> showAppTextPrompt(
  BuildContext context, {
  required String title,
  required String label,
  required String confirmLabel,
  String? message,
  String initialText = '',
  bool isRequired = true,
  bool destructive = false,
  int maxLines = 3,
}) => showAppDialog<String>(
  context,
  builder: (_) => _TextPrompt(
    title: title,
    label: label,
    confirmLabel: confirmLabel,
    message: message,
    initialText: initialText,
    isRequired: isRequired,
    destructive: destructive,
    maxLines: maxLines,
  ),
);

class _TextPrompt extends StatefulWidget {
  const _TextPrompt({
    required this.title,
    required this.label,
    required this.confirmLabel,
    required this.message,
    required this.initialText,
    required this.isRequired,
    required this.destructive,
    required this.maxLines,
  });

  final String title;
  final String label;
  final String confirmLabel;
  final String? message;
  final String initialText;
  final bool isRequired;
  final bool destructive;
  final int maxLines;

  @override
  State<_TextPrompt> createState() => _TextPromptState();
}

class _TextPromptState extends State<_TextPrompt> {
  late final _text = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool get _canConfirm => !widget.isRequired || _text.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final message = widget.message;
    return AppDialog(
      title: widget.title,
      actions: [
        AppButton(
          label: strings.cancel,
          variant: AppButtonVariant.plain,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          label: widget.confirmLabel,
          variant: widget.destructive ? AppButtonVariant.destructive : AppButtonVariant.filled,
          onPressed: _canConfirm ? () => Navigator.of(context).pop(_text.text.trim()) : null,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message != null) ...[
            Text(
              message,
              style: AppTypography.subheadline.copyWith(color: AppColors.textSecondary.resolveFrom(context)),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          AppTextField(
            label: widget.label,
            controller: _text,
            isRequired: widget.isRequired,
            autofocus: true,
            maxLines: widget.maxLines,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }
}
