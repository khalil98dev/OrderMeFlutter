import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/l10n/labels.dart';
import '../../../app/shell/admin_page.dart';
import '../../../app/widgets/submit_dialog.dart';
import '../../teachers/domain/teacher_directory.dart';
import '../domain/debts.dart';
import 'debt_dialogs.dart';

/// Everything one teacher owes, item by item. An invoice opens the invoice; a debt opens its dialog.
///
/// Expects a `LoadCubit<ClientDebts>` and [GetClientDebts], [GetDebt], [CreateDebt], [SettleDebt],
/// [WriteOffDebt] and [SearchTeachers] above it.
class ClientDebtsPage extends StatefulWidget {
  const ClientDebtsPage({super.key, required this.clientId});

  final String clientId;

  @override
  State<ClientDebtsPage> createState() => _ClientDebtsPageState();
}

class _ClientDebtsPageState extends State<ClientDebtsPage> {
  var _includeClosed = false;

  Future<void> _reload() {
    final get = context.read<GetClientDebts>();
    final params = ClientDebtsParams(widget.clientId, includeClosed: _includeClosed);
    return context.read<LoadCubit<ClientDebts>>().loadWith(() => get(params));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final cubit = context.read<LoadCubit<ClientDebts>>();
    final state = context.watch<LoadCubit<ClientDebts>>().state;
    final debts = state.data;

    return AdminPage(
      title: debts?.totals.clientName ?? strings.navDebts,
      subtitle: debts?.totals.phone,
      onBack: context.canPop() ? () => context.pop() : null,
      actions: [
        AppButton(
          label: strings.navWallet,
          icon: CupertinoIcons.money_dollar_circle,
          variant: AppButtonVariant.plain,
          onPressed: () => context.go('/wallet/${widget.clientId}'),
        ),
        AppButton(
          label: strings.newDebt,
          icon: CupertinoIcons.add,
          onPressed: () => _create(debts?.totals.clientName),
        ),
      ],
      child: AppLoadView(
        isLoading: state.isLoading || (!state.hasData && state.failure == null),
        hasData: debts != null,
        failure: state.failure,
        onRetry: cubit.load,
        empty: const SizedBox.shrink(),
        builder: (context) {
          final totals = debts!.totals;
          String money(num value) => MoneyFormat.dzd(value, locale);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  for (final (label, value, tone) in [
                    (strings.totalOwed, totals.totalOwed, AppTone.warning),
                    (strings.overdue, totals.overdue, AppTone.danger),
                    (strings.overdueInvoices, totals.overdueInvoices, AppTone.danger),
                    (strings.upcomingInvoices, totals.upcomingInvoices, AppTone.info),
                    (strings.openDebts, totals.openDebts, AppTone.neutral),
                    (strings.balance, totals.walletBalance, AppTone.success),
                  ])
                    SizedBox(
                      width: 190,
                      child: AppMetricCard(label: label, value: money(value), tone: tone),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppCheckbox(
                label: strings.includeClosed,
                value: _includeClosed,
                onChanged: (value) {
                  setState(() => _includeClosed = value);
                  _reload();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: debts.items.isEmpty
                    ? AppEmptyState(
                        icon: CupertinoIcons.checkmark_seal,
                        title: strings.noDebtsTitle,
                        tone: AppTone.success,
                      )
                    : AppTable(
                        columns: [
                          AppTableColumn(strings.colType, width: 100),
                          AppTableColumn(strings.colLabel, flex: 3),
                          AppTableColumn(strings.colDate, width: 110),
                          AppTableColumn(strings.dueDate, width: 110),
                          AppTableColumn.amount(strings.colAmount),
                          AppTableColumn.amount(strings.colPaid),
                          AppTableColumn.amount(strings.colDue),
                        ],
                        rowCount: debts.items.length,
                        onRowTap: (index) => _open(debts.items[index]),
                        cells: (context, index) {
                          final item = debts.items[index];
                          return [
                            AppBadge(
                              label: debtKindText(strings, item.kind),
                              tone: item.kind == DebtItemKind.invoice ? AppTone.info : AppTone.neutral,
                            ),
                            Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(AppDateFormat.day(item.date, locale)),
                            Text(AppDateFormat.day(item.dueDate, locale)),
                            AppMoney(item.amount, style: AppTypography.subheadline),
                            AppMoney(item.amountPaid, style: AppTypography.subheadline),
                            AppMoney(
                              item.amountDue,
                              style: AppTypography.subheadline,
                              tone: item.isOverdue ? AppTone.danger : null,
                            ),
                          ];
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _open(DebtItem item) async {
    if (item.kind == DebtItemKind.invoice) {
      context.go('/invoices/${item.id}');
      return;
    }
    final getDebt = context.read<GetDebt>();
    final settle = context.read<SettleDebt>();
    final writeOff = context.read<WriteOffDebt>();
    await showAppDialog<void>(
      context,
      builder: (_) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: settle),
          RepositoryProvider.value(value: writeOff),
        ],
        child: BlocProvider(
          create: (_) => LoadCubit<Debt>(() => getDebt(item.id))..load(),
          child: const DebtDialog(),
        ),
      ),
    );
    if (mounted) await _reload(); // it may have been settled or written off
  }

  Future<void> _create(String? clientName) async {
    final strings = AppStrings.of(context);
    final createDebt = context.read<CreateDebt>();
    final search = context.read<SearchTeachers>();
    final result = await showSubmitDialog<Debt>(
      context,
      builder: (_) => NewDebtDialog(
        createDebt: createDebt,
        searchTeachers: search,
        clientId: widget.clientId,
        clientName: clientName,
      ),
    );
    if (!result.saved || !mounted) return;
    showAppToast(context, strings.debtCreated, tone: AppTone.success);
    await _reload();
  }
}
