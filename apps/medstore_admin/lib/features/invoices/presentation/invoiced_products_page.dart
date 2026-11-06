import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/l10n/labels.dart';
import '../../../app/shell/admin_page.dart';
import '../../../app/widgets/period_bar.dart';
import '../../teachers/domain/teacher_directory.dart';
import '../../teachers/presentation/teacher_filter_field.dart';
import '../domain/invoice.dart';
import '../domain/invoice_repository.dart';

/// The invoices of a period added up by product: "Math Guide 3AS · 150 copies · 67 500 DA". A row
/// opens where that total comes from (each invoice line, its teacher and its orders). With one teacher
/// and "only unpaid", it is what that teacher still owes, product by product: for settling a debt.
///
/// Expects a `LoadCubit<InvoicedProducts>`, [ListInvoicedProducts] and [SearchTeachers] above it.
class InvoicedProductsPage extends StatefulWidget {
  const InvoicedProductsPage({super.key, required this.initialFilter});

  final InvoicedProductsFilter initialFilter;

  @override
  State<InvoicedProductsPage> createState() => _InvoicedProductsPageState();
}

class _InvoicedProductsPageState extends State<InvoicedProductsPage> {
  late var _filter = widget.initialFilter;

  void _setFilter(InvoicedProductsFilter filter) {
    setState(() => _filter = filter);
    final list = context.read<ListInvoicedProducts>();
    context.read<LoadCubit<InvoicedProducts>>().loadWith(() => list(filter));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final cubit = context.read<LoadCubit<InvoicedProducts>>();
    final state = context.watch<LoadCubit<InvoicedProducts>>().state;
    final summary = state.data;
    String money(num value) => MoneyFormat.dzd(value, locale);

    return AdminPage(
      title: strings.byProductTitle,
      subtitle: _filter.clientName ?? strings.byProductSubtitle,
      onBack: context.canPop() ? () => context.pop() : null,
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
                  teacherName: _filter.clientName,
                  onChanged: (teacher) => _setFilter(_filter.copyWith(client: () => teacher)),
                ),
              ),
              PeriodBar(
                from: _filter.from,
                to: _filter.to,
                width: 170,
                onChanged: (from, to) => _setFilter(_filter.copyWith(from: () => from, to: () => to)),
              ),
              AppCheckbox(
                label: strings.onlyUnpaid,
                value: _filter.onlyUnpaid,
                onChanged: (value) => _setFilter(_filter.copyWith(onlyUnpaid: value)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: AppLoadView(
              isLoading: state.isLoading || (!state.hasData && state.failure == null),
              hasData: summary != null,
              failure: state.failure,
              onRetry: cubit.load,
              empty: const SizedBox.shrink(),
              builder: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      for (final (label, value, tone) in [
                        (strings.totalQuantity, '${summary!.quantity}', AppTone.accent),
                        (strings.total, money(summary.total), AppTone.info),
                        (strings.leftAsDebt, money(summary.amountDue), AppTone.warning),
                        (strings.colInvoices, '${summary.invoiceCount}', AppTone.neutral),
                      ])
                        SizedBox(
                          width: 200,
                          child: AppMetricCard(label: label, value: value, tone: tone),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: summary.products.isEmpty
                        ? AppEmptyState(
                            icon: AppIcons.invoices,
                            title: strings.noInvoicedProductsTitle,
                            message: strings.noInvoicedProductsMessage,
                          )
                        : AppTable(
                            columns: [
                              AppTableColumn(strings.colProduct, flex: 3),
                              AppTableColumn(strings.colInvoices, width: 90),
                              AppTableColumn(strings.colQuantity, width: 110),
                              AppTableColumn.amount(strings.colTotal),
                              AppTableColumn.amount(strings.colDue),
                              const AppTableColumn('', width: 40),
                            ],
                            rowCount: summary.products.length,
                            onRowTap: (index) => _showSources(summary.products[index]),
                            cells: (context, index) {
                              final product = summary.products[index];
                              return [
                                Text(
                                  [product.productName, ?product.productCode].join(' · '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text('${product.invoiceCount}'),
                                Text('${product.quantity}', style: AppTypography.headline),
                                AppMoney(product.total, style: AppTypography.subheadline),
                                AppMoney(
                                  product.amountDue,
                                  style: AppTypography.subheadline,
                                  tone: product.amountDue > 0 ? AppTone.warning : null,
                                ),
                                const Icon(AppIcons.forward, size: 16),
                              ];
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSources(InvoicedProduct product) async {
    final invoiceId = await showAppDialog<String>(context, builder: (_) => _SourcesDialog(product: product));
    if (invoiceId == null || !mounted) return;
    await context.push<String>('/invoices/$invoiceId');
    if (mounted) await context.read<LoadCubit<InvoicedProducts>>().load(); // it may have been paid
  }
}

/// Every invoice line behind one product's total. A row closes with its invoice id, to open it.
class _SourcesDialog extends StatelessWidget {
  const _SourcesDialog({required this.product});

  final InvoicedProduct product;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final sources = product.sources;

    return AppDialog(
      title: strings.invoicedProductSources(product.productName),
      width: 1000,
      actions: [
        AppButton(
          label: strings.close,
          variant: AppButtonVariant.plain,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.xs,
            children: [
              Text(strings.copiesCount(product.quantity), style: AppTypography.headline),
              AppMoney(product.total, style: AppTypography.headline),
              if (product.amountDue > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${strings.leftAsDebt} : ', style: AppTypography.subheadline),
                    AppMoney(product.amountDue, style: AppTypography.headline, tone: AppTone.warning),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTable(
            shrinkWrap: true,
            columns: [
              AppTableColumn(strings.colNumber, width: 120),
              AppTableColumn(strings.colTeacher, flex: 2),
              AppTableColumn(strings.issueDate, width: 105),
              AppTableColumn(strings.colOrders, flex: 2),
              AppTableColumn.amount(strings.colUnitPrice),
              AppTableColumn(strings.colQuantity, width: 70),
              AppTableColumn.amount(strings.colTotal),
              AppTableColumn.amount(strings.colDue),
              AppTableColumn(strings.fieldPaymentStatus, width: 140),
            ],
            rowCount: sources.length,
            onRowTap: (index) => Navigator.of(context).pop(sources[index].invoiceId),
            cells: (context, index) {
              final source = sources[index];
              return [
                Text(source.invoiceLabel),
                Text(source.clientName ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(AppDateFormat.day(source.issueDate, locale)),
                Text(
                  source.orders.map((order) => '${order.orderNumber} (${order.quantity})').join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppMoney(source.unitPrice, style: AppTypography.subheadline),
                Text('${source.quantity}'),
                AppMoney(source.lineTotal, style: AppTypography.subheadline),
                AppMoney(
                  source.amountDue,
                  style: AppTypography.subheadline,
                  tone: source.amountDue > 0 ? AppTone.warning : null,
                ),
                AppBadge(
                  label: paymentStatusText(strings, source.paymentStatus),
                  tone: paymentStatusTone(source.paymentStatus),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}
