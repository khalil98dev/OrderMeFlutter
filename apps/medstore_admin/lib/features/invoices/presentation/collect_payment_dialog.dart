import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/forms/form_values.dart';
import '../../../app/l10n/labels.dart';
import '../../../app/widgets/submit_dialog.dart';
import '../../wallets/domain/wallet.dart';
import '../domain/invoice.dart';
import '../domain/invoice_repository.dart';

/// The teacher pays this invoice at the counter. Recorded as a deposit (with its receipt) that pays this
/// invoice first; an empty amount pays exactly what is due. Closes with the updated invoice.
class CollectPaymentDialog extends StatefulWidget {
  const CollectPaymentDialog({super.key, required this.invoice, required this.collect});

  final Invoice invoice;
  final CollectInvoicePayment collect;

  @override
  State<CollectPaymentDialog> createState() => _CollectPaymentDialogState();
}

class _CollectPaymentDialogState extends State<CollectPaymentDialog> {
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  var _method = PaymentMethod.cash;
  var _amountInvalid = false;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final due = widget.invoice.summary.amountDue ?? 0;
    const gap = SizedBox(height: AppSpacing.md);

    return SubmitDialog<Invoice>(
      title: strings.collectPaymentTitle,
      submitLabel: strings.collectPayment,
      prepare: () {
        final text = _amount.text.trim();
        final amount = text.isEmpty ? null : parseMoney(text);
        setState(() => _amountInvalid = text.isNotEmpty && (amount == null || amount <= 0));
        if (_amountInvalid) return null;
        final draft = CollectDraft(method: _method, amount: amount, reference: optionalText(_reference.text));
        return () => widget.collect(CollectParams(widget.invoice.id, draft));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppMessage(text: strings.collectPaymentMessage(MoneyFormat.dzd(due, locale)), tone: AppTone.info),
          gap,
          AppTextField(
            label: strings.collectAmountLabel,
            controller: _amount,
            autofocus: true,
            placeholder: '$due',
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
        ],
      ),
    );
  }
}
