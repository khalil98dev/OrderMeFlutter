import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/files/save_file.dart';
import '../../../app/l10n/labels.dart';
import '../../../app/widgets/period_bar.dart';
import '../domain/statement.dart';
import '../domain/teacher_repository.dart';

/// A teacher's statement for a period: today's position, then the period's invoices, wallet movements and
/// open debts, with the PDF to hand out.
///
/// Expects a `LoadCubit<Statement>`, [GetStatement] and [DownloadStatementPdf] above it.
class StatementView extends StatefulWidget {
  const StatementView({
    super.key,
    required this.clientId,
    required this.initialFrom,
    required this.initialTo,
  });

  final String clientId;
  final DateTime initialFrom;
  final DateTime initialTo;

  @override
  State<StatementView> createState() => _StatementViewState();
}

class _StatementViewState extends State<StatementView> {
  late DateTime _from = widget.initialFrom;
  late DateTime _to = widget.initialTo;

  StatementParams get _params => StatementParams(widget.clientId, from: _from, to: _to);

  void _setPeriod(DateTime? from, DateTime? to) {
    setState(() {
      _from = from ?? _from;
      _to = to ?? _to;
    });
    final getStatement = context.read<GetStatement>();
    final params = _params;
    context.read<LoadCubit<Statement>>().loadWith(() => getStatement(params));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<Statement>>();
    final state = context.watch<LoadCubit<Statement>>().state;
    final download = context.read<DownloadStatementPdf>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: Text(strings.statement, style: AppTypography.title3)),
            PeriodBar(from: _from, to: _to, clearable: false, width: 170, onChanged: _setPeriod),
            const SizedBox(width: AppSpacing.sm),
            AppButton(
              label: strings.downloadPdf,
              icon: CupertinoIcons.arrow_down_doc,
              variant: AppButtonVariant.tinted,
              onPressed: () =>
                  savePdf(context, 'releve-${apiDay(_from)}-${apiDay(_to)}.pdf', () => download(_params)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppLoadView(
          isLoading: state.isLoading || (!state.hasData && state.failure == null),
          hasData: state.hasData,
          failure: state.failure,
          onRetry: cubit.load,
          empty: const SizedBox.shrink(),
          loading: const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(child: CupertinoActivityIndicator()),
          ),
          builder: (context) => _StatementBody(statement: state.data!),
        ),
      ],
    );
  }
}

class _StatementBody extends StatelessWidget {
  const _StatementBody({required this.statement});

  final Statement statement;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final totals = statement.totals;
    String money(num value) => MoneyFormat.dzd(value, locale);
    const gap = SizedBox(height: AppSpacing.lg);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final (label, value, tone) in [
              (strings.totalsInvoiced, totals.invoiced, AppTone.neutral),
              (strings.totalsDeposited, totals.deposited, AppTone.success),
              (strings.totalsPaidFromWallet, totals.paidFromWallet, AppTone.info),
              (strings.owedNow, totals.owedNow, AppTone.warning),
              (strings.overdueNow, totals.overdueNow, AppTone.danger),
              (strings.walletBalanceNow, totals.walletBalanceNow, AppTone.brand),
            ])
              SizedBox(
                width: 200,
                child: AppMetricCard(label: label, value: money(value), tone: tone),
              ),
          ],
        ),
        gap,
        AppFieldLabel(strings.statementInvoices),
        if (statement.invoices.isEmpty)
          Text(strings.nothingInPeriod)
        else
          AppTable(
            shrinkWrap: true,
            columns: [
              AppTableColumn(strings.colNumber, flex: 2),
              AppTableColumn(strings.issueDate, width: 120),
              AppTableColumn(strings.dueDate, width: 120),
              AppTableColumn.amount(strings.colTotal),
              AppTableColumn.amount(strings.colPaid),
              AppTableColumn.amount(strings.colDue),
            ],
            rowCount: statement.invoices.length,
            cells: (context, index) {
              final invoice = statement.invoices[index];
              return [
                Row(
                  children: [
                    Text(invoice.label),
                    if (invoice.isVoided) ...[
                      const SizedBox(width: AppSpacing.xs),
                      AppBadge(label: strings.voidedBadge),
                    ] else if (invoice.isOverdue) ...[
                      const SizedBox(width: AppSpacing.xs),
                      AppBadge(label: strings.overdue, tone: AppTone.danger),
                    ],
                  ],
                ),
                Text(AppDateFormat.day(invoice.issueDate, locale)),
                Text(AppDateFormat.day(invoice.dueDate, locale)),
                AppMoney(invoice.total, style: AppTypography.subheadline),
                AppMoney(invoice.amountPaid, style: AppTypography.subheadline),
                AppMoney(invoice.amountDue, style: AppTypography.subheadline),
              ];
            },
          ),
        gap,
        AppFieldLabel(strings.statementMovements),
        if (statement.movements.isEmpty)
          Text(strings.nothingInPeriod)
        else
          AppTable(
            shrinkWrap: true,
            columns: [
              AppTableColumn(strings.colDate, width: 150),
              AppTableColumn(strings.colType, flex: 2),
              AppTableColumn(strings.colReceipt, width: 120),
              AppTableColumn.amount(strings.colAmount),
              AppTableColumn.amount(strings.colBalanceAfter),
            ],
            rowCount: statement.movements.length,
            cells: (context, index) {
              final movement = statement.movements[index];
              return [
                Text(AppDateFormat.dateTime(movement.occurredAt, locale)),
                Row(
                  children: [
                    Flexible(child: Text(transactionTypeText(strings, movement.type), maxLines: 1)),
                    if (movement.isVoided) ...[
                      const SizedBox(width: AppSpacing.xs),
                      AppBadge(label: strings.voidedBadge),
                    ],
                  ],
                ),
                Text(movement.receiptLabel ?? '—'),
                AppMoney(
                  movement.amount,
                  style: AppTypography.subheadline,
                  tone: amountTone(movement.amount),
                ),
                AppMoney(movement.balanceAfter, style: AppTypography.subheadline),
              ];
            },
          ),
        gap,
        AppFieldLabel(strings.statementOpenDebts),
        if (statement.openDebts.isEmpty)
          Text(strings.nothingInPeriod)
        else
          AppTable(
            shrinkWrap: true,
            columns: [
              AppTableColumn(strings.fieldDescription, flex: 3),
              AppTableColumn(strings.dueDate, width: 120),
              AppTableColumn.amount(strings.colAmount),
              AppTableColumn.amount(strings.colDue),
            ],
            rowCount: statement.openDebts.length,
            cells: (context, index) {
              final debt = statement.openDebts[index];
              return [
                Text(debt.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(AppDateFormat.day(debt.dueDate, locale)),
                AppMoney(debt.amount, style: AppTypography.subheadline),
                AppMoney(
                  debt.amountDue,
                  style: AppTypography.subheadline,
                  tone: debt.isOverdue ? AppTone.danger : null,
                ),
              ];
            },
          ),
      ],
    );
  }
}
