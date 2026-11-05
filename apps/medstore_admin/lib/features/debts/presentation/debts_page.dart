import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/shell/admin_page.dart';
import '../../../app/widgets/paged_table.dart';
import '../../../app/widgets/submit_dialog.dart';
import '../../teachers/domain/teacher_directory.dart';
import '../domain/debts.dart';
import 'debt_dialogs.dart';

typedef DebtOverviewCubit = PagedListCubit<DebtOverview, DebtFilter>;

/// Who owes what, most overdue first. A row opens the teacher's items; "New debt" enters one by hand.
///
/// Expects a [DebtOverviewCubit], [CreateDebt] and [SearchTeachers] above it.
class DebtsPage extends StatelessWidget {
  const DebtsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final cubit = context.read<DebtOverviewCubit>();
    final filter = context.select<DebtOverviewCubit, DebtFilter>((cubit) => cubit.state.filter);
    final total = context.select<DebtOverviewCubit, int>((cubit) => cubit.state.totalCount);

    return AdminPage(
      title: strings.navDebts,
      subtitle: total > 0 ? strings.teachersCount(total) : null,
      actions: [
        AppButton(label: strings.newDebt, icon: CupertinoIcons.add, onPressed: () => _create(context)),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppSearchField(
                  placeholder: strings.searchTeachers,
                  onChanged: (text) => cubit.setFilter(DebtFilter(search: text, onlyOwing: filter.onlyOwing)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              AppCheckbox(
                label: strings.onlyOwing,
                value: filter.onlyOwing,
                onChanged: (value) => cubit.setFilter(DebtFilter(search: filter.search, onlyOwing: value)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: PagedTable<DebtOverview, DebtFilter>(
              columns: [
                AppTableColumn(strings.colTeacher, flex: 3),
                AppTableColumn(strings.oldestDue, width: 140),
                AppTableColumn.amount(strings.overdueInvoices),
                AppTableColumn.amount(strings.upcomingInvoices),
                AppTableColumn.amount(strings.openDebts),
                AppTableColumn.amount(strings.balance),
                AppTableColumn.amount(strings.totalOwed, width: 140),
              ],
              onTap: (row) async {
                await context.push('/debts/${row.clientId}');
                await cubit.load();
              },
              empty: AppEmptyState(
                icon: CupertinoIcons.checkmark_seal,
                title: strings.noDebtsTitle,
                message: strings.noDebtsMessage,
                tone: AppTone.success,
              ),
              cells: (context, row) => [
                Text(row.clientName, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(row.oldestDueDate == null ? '—' : AppDateFormat.day(row.oldestDueDate!, locale)),
                AppMoney(
                  row.overdueInvoices,
                  style: AppTypography.subheadline,
                  tone: row.overdueInvoices > 0 ? AppTone.danger : null,
                ),
                AppMoney(row.upcomingInvoices, style: AppTypography.subheadline),
                AppMoney(row.openDebts, style: AppTypography.subheadline),
                AppMoney(row.walletBalance, style: AppTypography.subheadline, tone: AppTone.success),
                AppMoney(
                  row.totalOwed,
                  style: AppTypography.headline,
                  tone: row.overdue > 0 ? AppTone.danger : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _create(BuildContext context) async {
    final strings = AppStrings.of(context);
    final cubit = context.read<DebtOverviewCubit>();
    final createDebt = context.read<CreateDebt>();
    final search = context.read<SearchTeachers>();
    final result = await showSubmitDialog<Debt>(
      context,
      builder: (_) => NewDebtDialog(createDebt: createDebt, searchTeachers: search),
    );
    if (!result.saved || !context.mounted) return;
    showAppToast(context, strings.debtCreated, tone: AppTone.success);
    await cubit.load();
  }
}
