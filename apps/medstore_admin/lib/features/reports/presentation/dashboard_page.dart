import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/l10n/labels.dart';
import '../../../app/shell/admin_page.dart';
import '../../../app/widgets/period_bar.dart';
import '../domain/reports.dart';

/// The period at a glance (the month so far by default) and today's position.
///
/// Expects a `LoadCubit<SummaryReport>` and [GetSummaryReport] above it.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.initialPeriod});

  final ReportPeriod initialPeriod;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late ReportPeriod _period = widget.initialPeriod;

  void _setPeriod(DateTime? from, DateTime? to) {
    setState(() => _period = ReportPeriod(from: from, to: to));
    final summary = context.read<GetSummaryReport>();
    final period = _period;
    context.read<LoadCubit<SummaryReport>>().loadWith(() => summary(period));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<SummaryReport>>();
    final state = context.watch<LoadCubit<SummaryReport>>().state;

    return AdminPage(
      title: strings.navDashboard,
      actions: [
        PeriodBar(from: _period.from, to: _period.to, width: 170, onChanged: _setPeriod),
        AppIconButton(icon: AppIcons.refresh, label: strings.refresh, onPressed: cubit.load),
      ],
      child: AppLoadView(
        isLoading: state.isLoading || (!state.hasData && state.failure == null),
        hasData: state.hasData,
        failure: state.failure,
        onRetry: cubit.load,
        empty: const SizedBox.shrink(),
        builder: (context) => SingleChildScrollView(child: _Summary(report: state.data!)),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.report});

  final SummaryReport report;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    String money(num value) => MoneyFormat.dzd(value, locale);

    Widget group(String title, List<(String, String, IconData?, AppTone)> metrics) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFieldLabel(title),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final (label, value, icon, tone) in metrics)
              SizedBox(
                width: 230,
                child: AppMetricCard(
                  label: label,
                  value: value,
                  icon: icon,
                  tone: tone,
                  // What is owed now is the figure the team opens the dashboard for.
                  prominent: label == strings.owedNow,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        group(strings.today, [
          (strings.owedNow, money(report.owedNow), AppIcons.error, AppTone.warning),
          (strings.overdueNow, money(report.overdueNow), AppIcons.clock, AppTone.danger),
          (strings.heldInWallets, money(report.heldInWalletsNow), AppIcons.wallet, AppTone.success),
          (strings.activeTeachers, '${report.activeTeachers}', AppIcons.teachers, AppTone.info),
        ]),
        group(
          '${strings.thePeriod} · ${AppDateFormat.day(report.from, locale)} – ${AppDateFormat.day(report.to, locale)}',
          [
            (strings.ordersPlaced, '${report.ordersPlaced}', AppIcons.cart, AppTone.accent),
            (strings.copiesOrdered, '${report.copiesOrdered}', AppIcons.products, AppTone.neutral),
            (strings.amountOrdered, money(report.amountOrdered), null, AppTone.neutral),
            (strings.invoicesIssued, '${report.invoicesIssued}', AppIcons.invoices, AppTone.info),
            (strings.amountInvoiced, money(report.amountInvoiced), null, AppTone.info),
            (strings.depositsCount, '${report.deposits}', AppIcons.downloadCircle, AppTone.success),
            (strings.amountDeposited, money(report.amountDeposited), null, AppTone.success),
            (strings.amountPaidFromWallets, money(report.amountPaidFromWallets), null, AppTone.success),
            (strings.newTeachers, '${report.newTeachers}', AppIcons.addPerson, AppTone.accent),
          ],
        ),
        group(strings.ordersByStatus, [
          for (final MapEntry(key: status, value: count) in report.ordersByStatus.entries)
            (orderStatusText(strings, status), '$count', null, orderStatusTone(status)),
        ]),
      ],
    );
  }
}
