import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../widgets/gallery_section.dart';

enum _Terms { immediate, endOfMonth, endOfYear }

/// The controls of the admin forms: picker fields, dates, switches, tick boxes, dialogs and prompts.
class FormsSection extends StatefulWidget {
  const FormsSection({super.key});

  @override
  State<FormsSection> createState() => _FormsSectionState();
}

class _FormsSectionState extends State<FormsSection> {
  _Terms? _terms = _Terms.endOfMonth;
  _Terms? _filter;
  DateTime? _from = DateTime(2026, 11);
  var _autoSettle = true;
  var _includeVoided = false;
  var _read = true;
  var _set = false;
  String? _reason;

  Map<_Terms, String> _termsText(BuildContext context) => {
    _Terms.immediate: tr(context, 'Comptant', 'فوري'),
    _Terms.endOfMonth: tr(context, 'Fin de mois', 'نهاية الشهر'),
    _Terms.endOfYear: tr(context, "Fin d'année", 'نهاية السنة'),
  };

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return GallerySection(
      title: tr(context, 'Formulaires', 'النماذج'),
      components:
          'AppFieldLabel · AppFieldBox · AppSelectField · AppDateField · AppSwitchRow · AppCheckbox · '
          'AppDialog · showAppTextPrompt',
      children: [
        Demo(
          label: 'AppSelectField · AppFieldBox',
          child: Column(
            children: [
              AppSelectField<_Terms>(
                label: strings.fieldPaymentTerms,
                options: _termsText(context),
                value: _terms,
                isRequired: true,
                onChanged: (value) => setState(() => _terms = value),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSelectField<_Terms>(
                label: tr(context, 'Filtre (avec « Tous »)', 'مرشح (مع «الكل»)'),
                options: _termsText(context),
                value: _filter,
                allowNone: true,
                onChanged: (value) => setState(() => _filter = value),
              ),
              const SizedBox(height: AppSpacing.md),
              AppFieldBox(
                label: strings.fieldTeacher,
                placeholder: strings.chooseTeacher,
                icon: AppIcons.person,
                errorText: strings.fieldRequired,
                isRequired: true,
                onTap: () {},
              ),
            ],
          ),
        ),
        Demo(
          label: 'AppDateField · AppSwitchRow · AppCheckbox',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDateField(
                label: strings.periodFrom,
                value: _from,
                onChanged: (value) => setState(() => _from = value),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSwitchRow(
                label: strings.autoSettle,
                description: strings.autoSettleHint,
                value: _autoSettle,
                onChanged: (value) => setState(() => _autoSettle = value),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCheckbox(
                label: strings.includeVoided,
                value: _includeVoided,
                onChanged: (value) => setState(() => _includeVoided = value),
              ),
              Row(
                children: [
                  const AppFieldLabel('Order'),
                  const Spacer(),
                  AppCheckbox(
                    label: 'Order · ${strings.permRead}',
                    showLabel: false,
                    value: _read,
                    onChanged: (value) => setState(() => _read = value),
                  ),
                  AppCheckbox(
                    label: 'Order · ${strings.permSet}',
                    showLabel: false,
                    value: _set,
                    onChanged: (value) => setState(() => _set = value),
                  ),
                  AppCheckbox(
                    label: 'Order · ${strings.permDelete}',
                    showLabel: false,
                    value: false,
                    onChanged: null,
                  ),
                ],
              ),
            ],
          ),
        ),
        Demo(
          label: 'AppDialog · showAppTextPrompt',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppButton(
                label: strings.newDeposit,
                icon: AppIcons.add,
                onPressed: () => showAppDialog<void>(
                  context,
                  builder: (context) => AppDialog(
                    title: strings.newDeposit,
                    actions: [
                      AppButton(
                        label: strings.cancel,
                        variant: AppButtonVariant.plain,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      AppButton(label: strings.save, onPressed: () => Navigator.of(context).pop()),
                    ],
                    child: Column(
                      children: [
                        AppTextField(label: strings.fieldAmount, placeholder: '15000', isRequired: true),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(label: strings.fieldReference, placeholder: strings.referenceHint),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: strings.voidInvoice,
                variant: AppButtonVariant.destructive,
                onPressed: () async {
                  final reason = await showAppTextPrompt(
                    context,
                    title: strings.voidInvoice,
                    message: strings.voidInvoiceMessage,
                    label: strings.fieldReason,
                    confirmLabel: strings.voidAction,
                    destructive: true,
                  );
                  setState(() => _reason = reason);
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'reason: ${_reason ?? 'null'}',
                style: AppTypography.footnote.copyWith(color: AppColors.textSecondary.resolveFrom(context)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
