import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/files/save_file.dart';
import '../../../app/forms/form_values.dart';
import '../../../app/l10n/labels.dart';
import '../../../app/shell/admin_page.dart';
import '../../../app/widgets/submit_dialog.dart';
import '../domain/invoice.dart';
import '../domain/invoice_repository.dart';
import 'collect_payment_dialog.dart';
import 'invoices_page.dart';

/// One invoice: lines and the orders they came from, payments, and the PDF, settle and void actions.
///
/// Expects a `LoadCubit<Invoice>`, [VoidInvoice], [SettleInvoice], [CollectInvoicePayment] and
/// [DownloadInvoicePdf] above it.
class InvoiceDetailPage extends StatelessWidget {
  const InvoiceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<Invoice>>();
    final state = context.watch<LoadCubit<Invoice>>().state;
    final invoice = state.data;

    return AdminPage(
      title: invoice?.summary.label ?? strings.navInvoices,
      subtitle: invoice?.summary.clientName,
      onBack: () => context.pop(),
      actions: [
        if (invoice != null) ...[
          AppButton(
            label: strings.downloadPdf,
            icon: AppIcons.download,
            variant: AppButtonVariant.plain,
            onPressed: () => savePdf(
              context,
              '${invoice.summary.label}.pdf',
              () => context.read<DownloadInvoicePdf>()(invoice.id),
            ),
          ),
          if (invoice.canSettle) ...[
            AppButton(
              label: strings.settleFromWallet,
              variant: AppButtonVariant.tinted,
              onPressed: () => _settle(context, invoice),
            ),
            AppButton(
              label: strings.collectPayment,
              icon: AppIcons.wallet,
              onPressed: () => _collect(context, invoice),
            ),
          ],
          if (!invoice.summary.isVoided)
            AppButton(
              label: strings.voidInvoice,
              variant: AppButtonVariant.destructive,
              onPressed: () => _void(context, invoice),
            ),
        ],
      ],
      child: AppLoadView(
        isLoading: state.isLoading || (!state.hasData && state.failure == null),
        hasData: invoice != null,
        failure: state.failure,
        onRetry: cubit.load,
        empty: const SizedBox.shrink(),
        builder: (context) => _InvoiceBody(invoice: invoice!),
      ),
    );
  }

  static Future<void> _settle(BuildContext context, Invoice invoice) async {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<Invoice>>();
    final settle = context.read<SettleInvoice>();
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
    final result = await settle(SettleParams(invoice.id, amount: amount));
    if (!context.mounted) return;
    switch (result) {
      case Ok(:final value):
        cubit.show(value);
        showAppToast(context, strings.invoiceSettled, tone: AppTone.success);
      case Err(:final failure):
        showAppToast(context, problemText(strings, failure), tone: AppTone.danger);
    }
  }

  /// The teacher pays at the counter: a deposit that pays this invoice first.
  static Future<void> _collect(BuildContext context, Invoice invoice) async {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<Invoice>>();
    final collect = context.read<CollectInvoicePayment>();
    final result = await showSubmitDialog<Invoice>(
      context,
      builder: (_) => CollectPaymentDialog(invoice: invoice, collect: collect),
    );
    if (!result.saved || !context.mounted) return;
    cubit.show(result.value!);
    showAppToast(context, strings.paymentCollected, tone: AppTone.success);
  }

  static Future<void> _void(BuildContext context, Invoice invoice) async {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<Invoice>>();
    final voidInvoice = context.read<VoidInvoice>();
    final reason = await showAppTextPrompt(
      context,
      title: strings.voidInvoice,
      message: strings.voidInvoiceMessage,
      label: strings.fieldReason,
      confirmLabel: strings.voidAction,
      destructive: true,
    );
    if (reason == null || !context.mounted) return;
    final result = await voidInvoice(VoidInvoiceParams(invoice.id, reason));
    if (!context.mounted) return;
    switch (result) {
      case Ok():
        showAppToast(context, strings.invoiceVoided, tone: AppTone.success);
        await cubit.load();
      case Err(:final failure):
        showAppToast(context, problemText(strings, failure), tone: AppTone.danger);
    }
  }
}

class _InvoiceBody extends StatelessWidget {
  const _InvoiceBody({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final summary = invoice.summary;
    final voidedAt = invoice.voidedAt;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (summary.isVoided)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppMessage(
                text: [
                  strings.voidedBadge,
                  if (voidedAt != null) AppDateFormat.dateTime(voidedAt, locale),
                  ?invoice.voidReason,
                ].join(' · '),
                tone: AppTone.warning,
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppCard(
                  child: Column(
                    children: [
                      AppInfoRow(
                        label: strings.colStatus,
                        child: InvoiceStatusBadge(invoice: summary),
                      ),
                      AppInfoRow(
                        label: strings.issueDate,
                        value: AppDateFormat.day(summary.issueDate, locale),
                      ),
                      AppInfoRow(label: strings.dueDate, value: AppDateFormat.day(summary.dueDate, locale)),
                      AppInfoRow(
                        label: strings.fieldPaymentTerms,
                        value: paymentTermsText(strings, invoice.paymentTerms),
                      ),
                      if (invoice.notes != null) AppInfoRow(label: strings.fieldNotes, value: invoice.notes),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: AppCard(
                  child: Column(
                    children: [
                      AppInfoRow(
                        label: strings.total,
                        child: AppMoney(summary.total, style: AppTypography.subheadline),
                      ),
                      AppInfoRow(
                        label: strings.amountPaid,
                        child: summary.amountPaid == null
                            ? const Text('—')
                            : AppMoney(
                                summary.amountPaid!,
                                style: AppTypography.subheadline,
                                tone: AppTone.success,
                              ),
                      ),
                      AppInfoRow(
                        label: strings.amountDue,
                        emphasized: true,
                        child: summary.amountDue == null
                            ? const Text('—')
                            : AppMoney(
                                summary.amountDue!,
                                style: AppTypography.headline,
                                tone: (summary.isOverdue ?? false) ? AppTone.danger : null,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppFieldLabel(strings.orderLines),
          AppTable(
            shrinkWrap: true,
            columns: [
              AppTableColumn(strings.colProduct, flex: 3),
              AppTableColumn(strings.colOrders, flex: 2),
              AppTableColumn.amount(strings.colUnitPrice),
              AppTableColumn(strings.colQuantity, width: 70),
              AppTableColumn.amount(strings.colTotal),
            ],
            rowCount: invoice.lines.length,
            cells: (context, index) {
              final line = invoice.lines[index];
              return [
                Text(line.productName, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  line.orders.map((order) => '${order.orderNumber} (${order.quantity})').join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppMoney(line.unitPrice, style: AppTypography.subheadline),
                Text('${line.quantity}'),
                AppMoney(line.lineTotal, style: AppTypography.subheadline),
              ];
            },
          ),
          if (invoice.payments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            AppSection(
              header: strings.invoicePayments,
              children: [
                for (final payment in invoice.payments)
                  AppListTile(
                    title: AppDateFormat.dateTime(payment.paidAt, locale),
                    subtitle: payment.refundedAt == null
                        ? null
                        : strings.refundedOn(AppDateFormat.dateTime(payment.refundedAt!, locale)),
                    trailing: AppMoney(payment.amount, style: AppTypography.subheadline),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
