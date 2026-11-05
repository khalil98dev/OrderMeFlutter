import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/forms/form_values.dart';
import '../../../app/l10n/labels.dart';
import '../../../app/widgets/submit_dialog.dart';
import '../domain/wallet.dart';
import '../domain/wallet_repository.dart';

/// Records money a teacher paid in. Closes with the new entry (its receipt number).
class DepositDialog extends StatefulWidget {
  const DepositDialog({super.key, required this.clientId, required this.recordDeposit});

  final String clientId;
  final RecordDeposit recordDeposit;

  @override
  State<DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends State<DepositDialog> {
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _note = TextEditingController();
  var _method = PaymentMethod.cash;
  var _amountInvalid = false;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    const gap = SizedBox(height: AppSpacing.md);
    return SubmitDialog<WalletTransaction>(
      title: strings.newDeposit,
      prepare: () {
        final draft = DepositDraft(
          amount: parseMoney(_amount.text),
          method: _method,
          reference: optionalText(_reference.text),
          note: optionalText(_note.text),
        );
        setState(() => _amountInvalid = draft.amount == null);
        if (_amountInvalid) return null;
        return () => widget.recordDeposit(DepositParams(widget.clientId, draft));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: strings.fieldAmount,
            controller: _amount,
            isRequired: true,
            autofocus: true,
            placeholder: '15000',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: _amountInvalid ? strings.amountInvalid : null,
          ),
          gap,
          AppSelectField<PaymentMethod>(
            label: strings.fieldMethod,
            options: {for (final method in PaymentMethod.values) method: paymentMethodText(strings, method)},
            value: _method,
            onChanged: (value) => setState(() => _method = value ?? _method),
          ),
          gap,
          AppTextField(
            label: strings.fieldReference,
            controller: _reference,
            placeholder: strings.referenceHint,
          ),
          gap,
          AppTextField(label: strings.fieldNote, controller: _note, maxLines: 2),
        ],
      ),
    );
  }
}

/// Records money handed back to a teacher (never more than the balance).
class WithdrawalDialog extends StatefulWidget {
  const WithdrawalDialog({super.key, required this.clientId, required this.recordWithdrawal});

  final String clientId;
  final RecordWithdrawal recordWithdrawal;

  @override
  State<WithdrawalDialog> createState() => _WithdrawalDialogState();
}

class _WithdrawalDialogState extends State<WithdrawalDialog> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  var _amountInvalid = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return SubmitDialog<WalletTransaction>(
      title: strings.newWithdrawal,
      prepare: () {
        final draft = WithdrawalDraft(amount: parseMoney(_amount.text), note: optionalText(_note.text));
        setState(() => _amountInvalid = draft.amount == null);
        if (_amountInvalid) return null;
        return () => widget.recordWithdrawal(WithdrawalParams(widget.clientId, draft));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppMessage(text: strings.withdrawalHint, tone: AppTone.info),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: strings.fieldAmount,
            controller: _amount,
            isRequired: true,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: _amountInvalid ? strings.amountInvalid : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: strings.fieldNote, controller: _note, maxLines: 2),
        ],
      ),
    );
  }
}
