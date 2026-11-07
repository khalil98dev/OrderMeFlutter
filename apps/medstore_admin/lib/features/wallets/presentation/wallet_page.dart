import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/files/save_file.dart';
import '../../../app/forms/form_values.dart';
import '../../../app/l10n/labels.dart';
import '../../../app/shell/admin_page.dart';
import '../../../app/widgets/paged_table.dart';
import '../../../app/widgets/period_bar.dart';
import '../../../app/widgets/submit_dialog.dart';
import '../domain/wallet.dart';
import '../domain/wallet_repository.dart';
import 'money_dialogs.dart';

typedef TransactionsCubit = PagedListCubit<WalletTransaction, TransactionFilter>;

/// One teacher's wallet: balance, deposits and withdrawals, settlement, and the ledger with receipts
/// and voids.
///
/// Expects a `LoadCubit<Wallet>`, a [TransactionsCubit] and the wallet use cases above it.
class WalletPage extends StatelessWidget {
  const WalletPage({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final wallet = context.select<LoadCubit<Wallet>, Wallet?>((cubit) => cubit.state.data);
    final failure = context.select<LoadCubit<Wallet>, Failure?>((cubit) => cubit.state.failure);

    return AdminPage(
      title: wallet?.clientName ?? strings.navWallet,
      subtitle: strings.navWallet,
      onBack: context.canPop() ? () => context.pop() : null,
      actions: [
        AppButton(
          label: strings.settleNow,
          variant: AppButtonVariant.plain,
          onPressed: () => _settle(context),
        ),
        AppButton(
          label: strings.newWithdrawal,
          icon: AppIcons.remove,
          variant: AppButtonVariant.tinted,
          onPressed: () => _withdraw(context),
        ),
        AppButton(label: strings.newDeposit, icon: AppIcons.add, onPressed: () => _deposit(context)),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (failure != null && wallet == null) ...[
            AppMessage(text: problemText(strings, failure)),
            const SizedBox(height: AppSpacing.md),
          ],
          // The figures and the filters share one line when the window is wide enough; in a narrow
          // one the filters move under the figures instead of overflowing.
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 260,
                child: AppMetricCard(
                  label: strings.balance,
                  value: wallet == null ? '—' : MoneyFormat.dzd(wallet.balance, locale),
                  icon: AppIcons.wallet,
                  tone: AppTone.success,
                  prominent: true,
                ),
              ),
              SizedBox(
                width: 260,
                child: AppMetricCard(
                  label: strings.totalDeposited,
                  value: wallet == null ? '—' : MoneyFormat.dzd(wallet.totalDeposited, locale),
                  icon: AppIcons.deposit,
                  tone: AppTone.info,
                ),
              ),
              const _TransactionFilters(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Expanded(child: _Ledger()),
        ],
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    await Future.wait([context.read<LoadCubit<Wallet>>().load(), context.read<TransactionsCubit>().load()]);
  }

  Future<void> _deposit(BuildContext context) async {
    final strings = AppStrings.of(context);
    final record = context.read<RecordDeposit>();
    final result = await showSubmitDialog<WalletTransaction>(
      context,
      builder: (_) => DepositDialog(clientId: clientId, recordDeposit: record),
    );
    if (!result.saved || !context.mounted) return;
    showAppToast(context, strings.depositRecorded(result.value?.receiptLabel ?? ''), tone: AppTone.success);
    await _refresh(context);
  }

  Future<void> _withdraw(BuildContext context) async {
    final strings = AppStrings.of(context);
    final record = context.read<RecordWithdrawal>();
    final result = await showSubmitDialog<WalletTransaction>(
      context,
      builder: (_) => WithdrawalDialog(clientId: clientId, recordWithdrawal: record),
    );
    if (!result.saved || !context.mounted) return;
    showAppToast(context, strings.withdrawalRecorded, tone: AppTone.success);
    await _refresh(context);
  }

  Future<void> _settle(BuildContext context) async {
    final strings = AppStrings.of(context);
    final settle = context.read<SettleWallet>();
    final confirmed = await showAppConfirmDialog(
      context,
      title: strings.settleNow,
      message: strings.settleNowMessage,
      confirmLabel: strings.settleNow,
    );
    if (!confirmed) return;
    final result = await settle(clientId);
    if (!context.mounted) return;
    switch (result) {
      case Ok(:final value):
        final amount = MoneyFormat.dzd(value.paid, Localizations.localeOf(context));
        showAppToast(context, strings.settledAmount(amount), tone: AppTone.success);
        await _refresh(context);
      case Err(:final failure):
        showAppToast(context, problemText(strings, failure), tone: AppTone.danger);
    }
  }
}

class _TransactionFilters extends StatelessWidget {
  const _TransactionFilters();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<TransactionsCubit>();
    final filter = context.select<TransactionsCubit, TransactionFilter>((cubit) => cubit.state.filter);
    TransactionFilter filtered({WalletTransactionType? type, DateTime? from, DateTime? to}) =>
        TransactionFilter(clientId: filter.clientId, type: type, from: from, to: to);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        SizedBox(
          width: 200,
          child: AppSelectField<WalletTransactionType>(
            label: strings.colType,
            options: {
              for (final type in WalletTransactionType.values) type: transactionTypeText(strings, type),
            },
            value: filter.type,
            allowNone: true,
            noneLabel: strings.allTypes,
            onChanged: (type) => cubit.setFilter(filtered(type: type, from: filter.from, to: filter.to)),
          ),
        ),
        PeriodBar(
          from: filter.from,
          to: filter.to,
          width: 160,
          onChanged: (from, to) => cubit.setFilter(filtered(type: filter.type, from: from, to: to)),
        ),
      ],
    );
  }
}

class _Ledger extends StatelessWidget {
  const _Ledger();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    return PagedTable<WalletTransaction, TransactionFilter>(
      rowHeight: 48, // two lines at the Mac scale
      // Fixed widths only where the content has a known size (dates, amounts, buttons); the type and
      // the details share the rest, so neither is squeezed to a few letters.
      columns: [
        AppTableColumn(strings.colDate, width: 140),
        AppTableColumn(strings.colType, flex: 2),
        AppTableColumn(strings.fieldReference, flex: 3),
        AppTableColumn.amount(strings.colAmount, width: 120),
        AppTableColumn.amount(strings.colBalanceAfter, width: 120),
        const AppTableColumn('', width: 84),
      ],
      empty: AppEmptyState(icon: AppIcons.list, title: strings.noTransactionsTitle),
      cells: (context, entry) {
        final secondary = AppTypography.footnote.copyWith(
          color: AppColors.textSecondary.resolveFrom(context),
        );
        final details = [
          entry.method == null ? null : paymentMethodText(strings, entry.method!),
          entry.reference,
        ].whereType<String>().join(' · ');
        final extra = [entry.receiptLabel, entry.note].whereType<String>().join(' · ');
        return [
          Text(
            AppDateFormat.dateTime(entry.occurredAt, locale),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // The type, and under it "voided" when it was.
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(transactionTypeText(strings, entry.type), maxLines: 1, overflow: TextOverflow.ellipsis),
              if (entry.isVoided) ...[
                const SizedBox(height: AppSpacing.xxs),
                AppBadge(label: strings.voidedBadge, tone: AppTone.danger),
              ],
            ],
          ),
          // Method and reference; the receipt number and the note under them, quieter.
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(details.isEmpty ? '—' : details, maxLines: 1, overflow: TextOverflow.ellipsis),
              if (extra.isNotEmpty)
                Text(extra, maxLines: 1, overflow: TextOverflow.ellipsis, style: secondary),
            ],
          ),
          AppMoney(entry.amount, style: AppTypography.row, tone: amountTone(entry.amount)),
          AppMoney(entry.balanceAfter, style: AppTypography.row),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (entry.hasReceipt)
                AppIconButton(
                  icon: AppIcons.download,
                  label: strings.downloadReceipt,
                  onPressed: () => savePdf(
                    context,
                    '${entry.receiptLabel ?? 'receipt'}.pdf',
                    () => context.read<DownloadReceipt>()(entry.id),
                  ),
                ),
              if (entry.canBeVoided)
                AppIconButton(
                  icon: AppIcons.undo,
                  label: strings.voidTransaction,
                  tone: AppTone.danger,
                  onPressed: () => _void(context, entry),
                ),
            ],
          ),
        ];
      },
    );
  }

  static Future<void> _void(BuildContext context, WalletTransaction entry) async {
    final strings = AppStrings.of(context);
    final voidTransaction = context.read<VoidTransaction>();
    final wallet = context.read<LoadCubit<Wallet>>();
    final ledger = context.read<TransactionsCubit>();
    final reason = await showAppTextPrompt(
      context,
      title: strings.voidTransaction,
      message: strings.voidTransactionMessage,
      label: strings.fieldReason,
      confirmLabel: strings.voidAction,
      destructive: true,
    );
    if (reason == null || !context.mounted) return;
    final result = await voidTransaction(VoidTransactionParams(entry.id, reason));
    if (!context.mounted) return;
    switch (result) {
      case Ok():
        showAppToast(context, strings.transactionVoided, tone: AppTone.success);
        await Future.wait([wallet.load(), ledger.load()]);
      case Err(:final failure):
        showAppToast(context, problemText(strings, failure), tone: AppTone.danger);
    }
  }
}
