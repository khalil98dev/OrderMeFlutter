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
    final cubit = context.read<LoadCubit<InvoicedProducts>>();
    final state = context.watch<LoadCubit<InvoicedProducts>>().state;
    final summary = state.data;

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
              // As tall as a field, so the box lines up with them instead of floating above.
              SizedBox(
                height: 44,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 1,
                  child: AppCheckbox(
                    label: strings.onlyUnpaid,
                    value: _filter.onlyUnpaid,
                    onChanged: (value) => _setFilter(_filter.copyWith(onlyUnpaid: value)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
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
                  _Totals(summary: summary!),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: summary.products.isEmpty
                        ? AppEmptyState(
                            icon: AppIcons.invoices,
                            title: strings.noInvoicedProductsTitle,
                            message: strings.noInvoicedProductsMessage,
                          )
                        : _ProductsTable(summary: summary, onOpen: _showSources),
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

/// The period's four figures, side by side and sharing the width, two by two in a narrow window.
class _Totals extends StatelessWidget {
  const _Totals({required this.summary});

  final InvoicedProducts summary;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final cards = [
      AppMetricCard(
        label: strings.totalQuantity,
        value: '${summary.quantity}',
        icon: AppIcons.products,
        tone: AppTone.accent,
      ),
      AppMetricCard(
        label: strings.total,
        value: MoneyFormat.dzd(summary.total, locale),
        icon: AppIcons.invoices,
        tone: AppTone.info,
        prominent: true,
      ),
      AppMetricCard(
        label: strings.colDue,
        value: MoneyFormat.dzd(summary.amountDue, locale),
        icon: AppIcons.warning,
        tone: summary.amountDue > 0 ? AppTone.warning : AppTone.success,
      ),
      AppMetricCard(
        label: strings.colInvoices,
        value: '${summary.invoiceCount}',
        icon: AppIcons.documentDone,
        tone: AppTone.neutral,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        Widget row(List<Widget> children) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, card) in children.indexed) ...[
                if (index > 0) const SizedBox(width: AppSpacing.md),
                Expanded(child: card),
              ],
            ],
          ),
        );
        if (constraints.maxWidth >= 760) return row(cards);
        return Column(
          children: [
            row(cards.sublist(0, 2)),
            const SizedBox(height: AppSpacing.md),
            row(cards.sublist(2)),
          ],
        );
      },
    );
  }
}

/// One row per product: its name and code, its share of the copies, then the counts and amounts.
class _ProductsTable extends StatelessWidget {
  const _ProductsTable({required this.summary, required this.onOpen});

  final InvoicedProducts summary;
  final ValueChanged<InvoicedProduct> onOpen;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final secondary = AppTypography.footnote.copyWith(color: AppColors.textSecondary.resolveFrom(context));

    return AppTable(
      rowHeight: 48, // two lines at the Mac scale
      columns: [
        AppTableColumn(strings.colProduct, flex: 3),
        AppTableColumn(strings.colInvoices, width: 90),
        AppTableColumn(strings.colQuantity, width: 90),
        AppTableColumn.amount(strings.colTotal),
        AppTableColumn.amount(strings.colDue),
        const AppTableColumn('', width: 32),
      ],
      rowCount: summary.products.length,
      onRowTap: (index) => onOpen(summary.products[index]),
      cells: (context, index) {
        final product = summary.products[index];
        final share = summary.quantity == 0 ? 0.0 : product.quantity / summary.quantity;
        return [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.row.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (product.productCode case final code?) ...[
                    Text(code, style: secondary),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  // Its share of all the copies of the period.
                  Expanded(child: _ShareBar(share: share)),
                  const SizedBox(width: AppSpacing.xs),
                  Text('${(share * 100).round()} %', style: AppTypography.tabular(secondary)),
                ],
              ),
            ],
          ),
          Text('${product.invoiceCount}'),
          Text('${product.quantity}', style: AppTypography.tabular(AppTypography.headline)),
          AppMoney(product.total, style: AppTypography.row),
          _Due(amount: product.amountDue),
          const Icon(AppIcons.forward, size: 16),
        ];
      },
    );
  }
}

/// A thin bar filled to [share] (0 to 1), growing in when it first appears.
class _ShareBar extends StatelessWidget {
  const _ShareBar({required this.share});

  final double share;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent.resolveFrom(context);
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(2)),
      child: SizedBox(
        height: 4,
        child: ColoredBox(
          color: AppColors.accentTint.resolveFrom(context),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: share.clamp(0, 1)),
            duration: AppDurations.of(context, AppDurations.expand),
            curve: AppDurations.easeOut,
            builder: (context, value, _) => FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: value,
              child: ColoredBox(color: accent),
            ),
          ),
        ),
      ),
    );
  }
}

/// What is left to pay: orange when something is, a quiet dash when nothing is.
class _Due extends StatelessWidget {
  const _Due({required this.amount, this.style});

  final num amount;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (amount <= 0) {
      return Text('—', style: AppTypography.row.copyWith(color: AppColors.textTertiary.resolveFrom(context)));
    }
    return AppMoney(amount, style: style ?? AppTypography.row, tone: AppTone.warning);
  }
}

/// Every invoice line behind one product's total, one card each. A card closes the dialog with its
/// invoice id, to open it.
class _SourcesDialog extends StatelessWidget {
  const _SourcesDialog({required this.product});

  final InvoicedProduct product;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);

    return AppDialog(
      title: strings.invoicedProductSources(product.productName),
      width: 760,
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
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              AppBadge(label: strings.copiesCount(product.quantity), icon: AppIcons.products),
              AppBadge(
                label: MoneyFormat.dzd(product.total, locale),
                icon: AppIcons.invoices,
                tone: AppTone.info,
              ),
              if (product.amountDue > 0)
                AppBadge(
                  label: '${strings.leftAsDebt} : ${MoneyFormat.dzd(product.amountDue, locale)}',
                  icon: AppIcons.warning,
                  tone: AppTone.warning,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final (index, source) in product.sources.indexed) ...[
            if (index > 0) const SizedBox(height: AppSpacing.xs),
            _SourceCard(source: source, onTap: () => Navigator.of(context).pop(source.invoiceId)),
          ],
        ],
      ),
    );
  }
}

/// One invoice line: the invoice, its teacher and date, the orders it covers on the start side; the
/// amount, the price × copies, what is left and the payment status on the end side.
class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.source, required this.onTap});

  final InvoicedProductSource source;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final secondary = AppTypography.footnote.copyWith(color: AppColors.textSecondary.resolveFrom(context));

    return Semantics(
      button: true,
      label: strings.viewInvoice,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(source.invoiceLabel, style: AppTypography.row.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    [source.clientName ?? '—', AppDateFormat.day(source.issueDate, locale)].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: secondary,
                  ),
                  if (source.orders.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    // The orders this line bills, and how many copies each.
                    Wrap(
                      spacing: AppSpacing.xxs,
                      runSpacing: AppSpacing.xxs,
                      children: [
                        for (final order in source.orders)
                          AppBadge(
                            label: '${strings.orderNumber(order.orderNumber)} · ${order.quantity}',
                            icon: AppIcons.orders,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppMoney(source.lineTotal, style: AppTypography.headline),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${source.quantity} × ${MoneyFormat.dzd(source.unitPrice, locale)}',
                  style: AppTypography.tabular(secondary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (source.amountDue > 0) ...[
                      _Due(amount: source.amountDue, style: AppTypography.footnote),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    AppBadge(
                      label: paymentStatusText(strings, source.paymentStatus),
                      tone: paymentStatusTone(source.paymentStatus),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(AppIcons.forward, size: 16, color: AppColors.textTertiary.resolveFrom(context)),
          ],
        ),
      ),
    );
  }
}
