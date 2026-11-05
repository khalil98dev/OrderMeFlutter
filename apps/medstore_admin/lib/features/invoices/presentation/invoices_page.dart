import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/l10n/labels.dart';
import '../../../app/shell/admin_page.dart';
import '../../../app/widgets/paged_table.dart';
import '../../../app/widgets/period_bar.dart';
import '../../teachers/domain/teacher_directory.dart';
import '../../teachers/presentation/teacher_filter_field.dart';
import '../domain/invoice.dart';

typedef InvoicesCubit = PagedListCubit<InvoiceSummary, InvoiceFilter>;

/// Every invoice, newest first, filtered by teacher, payment, overdue, voided and issue date.
///
/// Expects an [InvoicesCubit] and [SearchTeachers] above it.
class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final cubit = context.read<InvoicesCubit>();
    final total = context.select<InvoicesCubit, int>((cubit) => cubit.state.totalCount);
    final filter = context.select<InvoicesCubit, InvoiceFilter>((cubit) => cubit.state.filter);

    return AdminPage(
      title: strings.navInvoices,
      subtitle: total > 0 ? strings.invoicesCount(total) : null,
      actions: [
        AppButton(
          label: strings.newInvoice,
          icon: CupertinoIcons.add,
          onPressed: () => _open(context, '/invoices/new'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 260,
                child: TeacherFilterField(
                  search: context.read<SearchTeachers>(),
                  teacherName: filter.clientName,
                  onChanged: (teacher) => cubit.setFilter(filter.copyWith(client: () => teacher)),
                ),
              ),
              SizedBox(
                width: 200,
                child: AppSelectField<InvoicePaymentStatus>(
                  label: strings.fieldPaymentStatus,
                  options: {
                    for (final status in InvoicePaymentStatus.values)
                      status: paymentStatusText(strings, status),
                  },
                  value: filter.paymentStatus,
                  allowNone: true,
                  onChanged: (status) => cubit.setFilter(filter.copyWith(paymentStatus: () => status)),
                ),
              ),
              PeriodBar(
                from: filter.from,
                to: filter.to,
                width: 170,
                onChanged: (from, to) => cubit.setFilter(filter.copyWith(from: () => from, to: () => to)),
              ),
              AppCheckbox(
                label: strings.onlyOverdue,
                value: filter.onlyOverdue,
                onChanged: (value) => cubit.setFilter(filter.copyWith(onlyOverdue: value)),
              ),
              AppCheckbox(
                label: strings.includeVoided,
                value: filter.includeVoided,
                onChanged: (value) => cubit.setFilter(filter.copyWith(includeVoided: value)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: PagedTable<InvoiceSummary, InvoiceFilter>(
              columns: [
                AppTableColumn(strings.colNumber, width: 120),
                AppTableColumn(strings.colTeacher, flex: 3),
                AppTableColumn(strings.issueDate, width: 110),
                AppTableColumn(strings.dueDate, width: 110),
                AppTableColumn(strings.fieldPaymentStatus, width: 160),
                AppTableColumn.amount(strings.colTotal),
                AppTableColumn.amount(strings.colDue),
              ],
              onTap: (invoice) => _open(context, '/invoices/${invoice.id}'),
              empty: AppEmptyState(
                icon: CupertinoIcons.doc_text,
                title: strings.noInvoicesTitle,
                message: strings.noInvoicesMessage,
              ),
              cells: (context, invoice) => [
                Text(invoice.label),
                Text(invoice.clientName ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(AppDateFormat.day(invoice.issueDate, locale)),
                Text(AppDateFormat.day(invoice.dueDate, locale)),
                InvoiceStatusBadge(invoice: invoice),
                AppMoney(invoice.total, style: AppTypography.subheadline),
                invoice.amountDue == null
                    ? const Text('—')
                    : AppMoney(
                        invoice.amountDue!,
                        style: AppTypography.subheadline,
                        tone: (invoice.isOverdue ?? false) ? AppTone.danger : null,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _open(BuildContext context, String path) async {
    final cubit = context.read<InvoicesCubit>();
    final message = await context.push<String>(path);
    if (!context.mounted) return;
    if (message != null) showAppToast(context, message, tone: AppTone.success);
    await cubit.load();
  }
}

/// Voided, overdue, or the payment status.
class InvoiceStatusBadge extends StatelessWidget {
  const InvoiceStatusBadge({super.key, required this.invoice});

  final InvoiceSummary invoice;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    if (invoice.isVoided) return AppBadge(label: strings.voidedBadge);
    if (invoice.isOverdue ?? false) return AppBadge(label: strings.overdue, tone: AppTone.danger);
    final status = invoice.paymentStatus;
    if (status == null) return const SizedBox.shrink();
    return AppBadge(label: paymentStatusText(strings, status), tone: paymentStatusTone(status));
  }
}
