import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/forms/form_values.dart';
import '../../../app/widgets/submit_dialog.dart';
import '../../invoices/domain/invoice_repository.dart' show SettleParams;
import '../../teachers/domain/teacher_directory.dart';
import '../../teachers/presentation/teacher_filter_field.dart';
import '../domain/debts.dart';

/// Enters a debt by hand (owed from before the app, an adjustment). [clientId] fixes the teacher.
class NewDebtDialog extends StatefulWidget {
  const NewDebtDialog({
    super.key,
    required this.createDebt,
    required this.searchTeachers,
    this.clientId,
    this.clientName,
  });

  final CreateDebt createDebt;
  final SearchTeachers searchTeachers;
  final String? clientId;
  final String? clientName;

  @override
  State<NewDebtDialog> createState() => _NewDebtDialogState();
}

class _NewDebtDialogState extends State<NewDebtDialog> {
  final _description = TextEditingController();
  final _amount = TextEditingController();
  late (String, String)? _teacher = widget.clientId == null
      ? null
      : (widget.clientId!, widget.clientName ?? '');
  DateTime? _dueDate;
  Set<DebtDraftField> _problems = const {};

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    const gap = SizedBox(height: AppSpacing.md);
    return SubmitDialog<Debt>(
      title: strings.newDebt,
      prepare: () {
        final draft = DebtDraft(
          clientId: _teacher?.$1,
          description: _description.text,
          amount: parseMoney(_amount.text),
          dueDate: _dueDate,
        );
        setState(() => _problems = draft.validate());
        if (_problems.isNotEmpty) return null;
        return () => widget.createDebt(draft);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TeacherFilterField(
            search: widget.searchTeachers,
            teacherName: _teacher?.$2,
            allowNone: false,
            errorText: _problems.contains(DebtDraftField.teacher) ? strings.fieldRequired : null,
            onChanged: widget.clientId != null ? (_) {} : (teacher) => setState(() => _teacher = teacher),
          ),
          gap,
          AppTextField(
            label: strings.fieldDescription,
            controller: _description,
            isRequired: true,
            placeholder: strings.debtDescriptionHint,
            errorText: _problems.contains(DebtDraftField.description) ? strings.fieldRequired : null,
          ),
          gap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: strings.fieldAmount,
                  controller: _amount,
                  isRequired: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  errorText: _problems.contains(DebtDraftField.amount) ? strings.amountInvalid : null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppDateField(
                  label: strings.dueDate,
                  value: _dueDate,
                  placeholder: strings.debtDueHint,
                  onChanged: (day) => setState(() => _dueDate = day),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One hand-entered debt, with its settle and write-off actions. Closes with `true` when it changed.
///
/// Expects a `LoadCubit<Debt>`, [SettleDebt] and [WriteOffDebt] above it.
class DebtDialog extends StatelessWidget {
  const DebtDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final state = context.watch<LoadCubit<Debt>>().state;
    final debt = state.data;
    final writtenOffAt = debt?.writtenOffAt;

    return AppDialog(
      title: debt?.description ?? strings.debtKindDebt,
      actions: [
        AppButton(
          label: strings.close,
          variant: AppButtonVariant.plain,
          onPressed: () => Navigator.of(context).pop(),
        ),
        if (debt != null && debt.isOpen) ...[
          AppButton(
            label: strings.writeOff,
            variant: AppButtonVariant.destructive,
            onPressed: () => _writeOff(context, debt),
          ),
          AppButton(label: strings.settleFromWallet, onPressed: () => _settle(context, debt)),
        ],
      ],
      child: AppLoadView(
        isLoading: state.isLoading || (!state.hasData && state.failure == null),
        hasData: debt != null,
        failure: state.failure,
        onRetry: context.read<LoadCubit<Debt>>().load,
        empty: const SizedBox.shrink(),
        loading: const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(child: CupertinoActivityIndicator()),
        ),
        builder: (context) => Column(
          children: [
            AppInfoRow(label: strings.colTeacher, value: debt!.clientName),
            AppInfoRow(label: strings.dueDate, value: AppDateFormat.day(debt.dueDate, locale)),
            AppInfoRow(
              label: strings.colAmount,
              child: AppMoney(debt.amount, style: AppTypography.row),
            ),
            AppInfoRow(
              label: strings.amountPaid,
              child: AppMoney(debt.amountPaid, style: AppTypography.row),
            ),
            if (debt.amountWrittenOff > 0)
              AppInfoRow(
                label: strings.writtenOff,
                child: AppMoney(debt.amountWrittenOff, style: AppTypography.row),
              ),
            AppInfoRow(
              label: strings.amountDue,
              emphasized: true,
              child: AppMoney(
                debt.amountDue,
                style: AppTypography.headline,
                tone: debt.isOverdue ? AppTone.danger : null,
              ),
            ),
            if (writtenOffAt != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AppMessage(
                text: strings.writtenOffOn(
                  AppDateFormat.day(writtenOffAt.toLocal(), locale),
                  debt.writeOffReason ?? '',
                ),
                tone: AppTone.info,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Future<void> _settle(BuildContext context, Debt debt) async {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<Debt>>();
    final settle = context.read<SettleDebt>();
    final text = await showAppTextPrompt(
      context,
      title: strings.settleFromWallet,
      label: strings.settleAmountLabel,
      confirmLabel: strings.settleFromWallet,
      isRequired: false,
      maxLines: 1,
    );
    if (text == null || !context.mounted) return;
    final amount = text.isEmpty ? null : parseMoney(text);
    if (text.isNotEmpty && amount == null) {
      showAppToast(context, strings.amountInvalid, tone: AppTone.danger);
      return;
    }
    final result = await settle(SettleParams(debt.id, amount: amount));
    if (context.mounted) _apply(context, cubit, result, strings.debtSettled);
  }

  static Future<void> _writeOff(BuildContext context, Debt debt) async {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<Debt>>();
    final writeOff = context.read<WriteOffDebt>();
    final reason = await showAppTextPrompt(
      context,
      title: strings.writeOff,
      message: strings.writeOffMessage,
      label: strings.fieldReason,
      confirmLabel: strings.writeOff,
      destructive: true,
    );
    if (reason == null || !context.mounted) return;
    final result = await writeOff(WriteOffParams(debt.id, reason));
    if (context.mounted) _apply(context, cubit, result, strings.debtWrittenOff);
  }

  static void _apply(BuildContext context, LoadCubit<Debt> cubit, Result<Debt> result, String done) {
    final strings = AppStrings.of(context);
    switch (result) {
      case Ok(:final value):
        cubit.show(value);
        showAppToast(context, done, tone: AppTone.success);
      case Err(:final failure):
        showAppToast(context, problemText(strings, failure), tone: AppTone.danger);
    }
  }
}
