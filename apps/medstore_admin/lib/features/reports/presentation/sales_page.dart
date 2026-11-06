import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/l10n/labels.dart';
import '../../../app/shell/admin_page.dart';
import '../../../app/widgets/period_bar.dart';
import '../domain/reports.dart';

/// What was ordered in a period, grouped by product, teacher, school, wilaya or month.
///
/// Expects a `LoadCubit<SalesReport>` and [GetSalesReport] above it.
class SalesPage extends StatefulWidget {
  const SalesPage({super.key, required this.initialPeriod});

  final ReportPeriod initialPeriod;

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  late ReportPeriod _period = widget.initialPeriod;
  var _groupBy = SalesGroupBy.product;

  void _reload() {
    final sales = context.read<GetSalesReport>();
    final params = SalesParams(_period, _groupBy);
    context.read<LoadCubit<SalesReport>>().loadWith(() => sales(params));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<SalesReport>>();
    final state = context.watch<LoadCubit<SalesReport>>().state;
    final report = state.data;

    return AdminPage(
      title: strings.salesReport,
      subtitle: report == null ? null : strings.ordersCount(report.orders),
      actions: [
        SizedBox(
          width: 200,
          child: AppSelectField<SalesGroupBy>(
            label: strings.groupBy,
            options: {for (final group in SalesGroupBy.values) group: groupByText(strings, group)},
            value: _groupBy,
            onChanged: (group) {
              setState(() => _groupBy = group ?? _groupBy);
              _reload();
            },
          ),
        ),
        PeriodBar(
          from: _period.from,
          to: _period.to,
          width: 170,
          onChanged: (from, to) {
            setState(() => _period = ReportPeriod(from: from, to: to));
            _reload();
          },
        ),
      ],
      child: AppLoadView(
        isLoading: state.isLoading || (!state.hasData && state.failure == null),
        hasData: report != null && report.rows.isNotEmpty,
        failure: state.failure,
        onRetry: cubit.load,
        empty: AppEmptyState(icon: AppIcons.reports, title: strings.noSalesTitle),
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AppTable(
                columns: [
                  AppTableColumn(groupByText(strings, report!.groupBy), flex: 3),
                  AppTableColumn(strings.colOrders, width: 110, alignment: AlignmentDirectional.centerEnd),
                  AppTableColumn(strings.colCopies, width: 110, alignment: AlignmentDirectional.centerEnd),
                  AppTableColumn.amount(strings.colAmount, width: 160),
                ],
                rowCount: report.rows.length,
                cells: (context, index) {
                  final row = report.rows[index];
                  return [
                    Text(row.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${row.orders}'),
                    Text('${row.copies}'),
                    AppMoney(row.amount, style: AppTypography.subheadline),
                  ];
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: SizedBox(
                width: 360,
                child: Column(
                  children: [
                    AppInfoRow(label: strings.colCopies, value: '${report.copies}'),
                    AppInfoRow(
                      label: strings.total,
                      emphasized: true,
                      child: AppMoney(report.amount, style: AppTypography.headline),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
