import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/forms/form_values.dart';
import '../../../app/shell/admin_page.dart';
import '../../teachers/domain/teacher_directory.dart';
import '../../teachers/presentation/teacher_filter_field.dart';
import '../domain/invoice.dart';
import 'new_invoice_cubit.dart';

/// Issues an invoice from a teacher's printed, not yet invoiced copies. Comes back with the toast text.
///
/// Expects a [NewInvoiceCubit] and [SearchTeachers] above it.
class NewInvoicePage extends StatelessWidget {
  const NewInvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<NewInvoiceCubit>();

    return BlocConsumer<NewInvoiceCubit, NewInvoiceState>(
      listenWhen: (previous, current) => current.issued != null && previous.issued == null,
      listener: (context, state) => context.pop(strings.invoiceIssued(state.issued!.summary.label)),
      builder: (context, state) {
        final draft = state.draft;
        return AdminPage(
          title: strings.newInvoice,
          onBack: state.isIssuing ? null : () => context.pop(),
          actions: [
            AppButton(
              label: strings.issueInvoice,
              icon: AppIcons.documentDone,
              isLoading: state.isIssuing,
              onPressed: cubit.issue,
            ),
          ],
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.failure case final failure?) ...[
                  AppMessage(text: problemText(strings, failure)),
                  const SizedBox(height: AppSpacing.md),
                ],
                for (final problem in state.problems) ...[
                  AppMessage(
                    text: switch (problem) {
                      InvoiceDraftProblem.teacherRequired => strings.chooseTeacherFirst,
                      InvoiceDraftProblem.nothingSelected => strings.nothingSelected,
                      InvoiceDraftProblem.quantityTooHigh => strings.failureValidation,
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 360,
                        child: TeacherFilterField(
                          search: context.read<SearchTeachers>(),
                          teacherName: state.teacherName,
                          allowNone: false,
                          onChanged: (teacher) {
                            if (teacher != null) cubit.chooseTeacher(teacher.$1, teacher.$2);
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppTextField(
                          label: strings.fieldNotes,
                          maxLines: 2,
                          onChanged: cubit.setNotes,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppFieldLabel(strings.uninvoicedTitle),
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: CupertinoActivityIndicator()),
                  )
                else if (draft.clientId != null && draft.available.isEmpty)
                  AppEmptyState(icon: AppIcons.invoices, title: strings.noUninvoiced)
                else if (draft.available.isNotEmpty) ...[
                  _UninvoicedTable(draft: draft),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: SizedBox(
                      width: 320,
                      child: AppInfoRow(
                        label: strings.total,
                        emphasized: true,
                        child: AppMoney(draft.total, style: AppTypography.headline),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UninvoicedTable extends StatelessWidget {
  const _UninvoicedTable({required this.draft});

  final InvoiceDraft draft;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<NewInvoiceCubit>();
    return AppTable(
      shrinkWrap: true,
      rowHeight: 64,
      columns: [
        AppTableColumn(strings.colProduct, flex: 3),
        AppTableColumn(strings.colOrders, flex: 2),
        AppTableColumn.amount(strings.colUnitPrice),
        AppTableColumn(strings.available, width: 80),
        AppTableColumn(strings.toInvoice, width: 150),
        AppTableColumn.amount(strings.colTotal),
      ],
      rowCount: draft.available.length,
      cells: (context, index) {
        final row = draft.available[index];
        final quantity = draft.quantityOf(row);
        return [
          Text(
            row.productCode == null ? row.productName : '${row.productName} (${row.productCode})',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            row.orders.map((line) => '${line.orderNumber} (${line.quantity})').join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          AppMoney(row.unitPrice, style: AppTypography.subheadline),
          Text('${row.quantity}'),
          AppQuantityStepper(
            value: quantity,
            min: 0,
            max: row.quantity,
            onChanged: (value) => cubit.setQuantity(row.key, value),
          ),
          AppMoney(row.unitPrice * quantity, style: AppTypography.subheadline),
        ];
      },
    );
  }
}
