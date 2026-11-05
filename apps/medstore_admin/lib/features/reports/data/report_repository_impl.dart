import 'package:medstore_core/medstore_core.dart';

import '../domain/reports.dart';

class ReportRepositoryImpl implements ReportRepository {
  const ReportRepositoryImpl(this._api);

  static const _path = '/api/admin/reports';

  final ApiClient _api;

  @override
  Future<Result<SummaryReport>> summary(ReportPeriod period) =>
      _api.get('$_path/summary', query: _period(period), decode: summaryFromJson);

  @override
  Future<Result<SalesReport>> sales(ReportPeriod period, SalesGroupBy groupBy) => _api.get(
    '$_path/sales',
    query: {..._period(period), 'groupBy': groupBy.apiName},
    decode: salesFromJson,
  );

  static Map<String, Object?> _period(ReportPeriod period) => {
    if (period.from != null) 'from': apiDay(period.from!),
    if (period.to != null) 'to': apiDay(period.to!),
  };

  static SummaryReport summaryFromJson(Object? raw) {
    final json = JsonMap.of(raw);
    final byStatus = json.object('ordersByStatus');
    return SummaryReport(
      from: json.day('from'),
      to: json.day('to'),
      ordersPlaced: json.integer('ordersPlaced'),
      copiesOrdered: json.integer('copiesOrdered'),
      amountOrdered: json.money('amountOrdered'),
      ordersByStatus: {
        OrderStatus.pending: byStatus.integer('pending'),
        OrderStatus.inPreparation: byStatus.integer('inPreparation'),
        OrderStatus.ready: byStatus.integer('ready'),
        OrderStatus.delivered: byStatus.integer('delivered'),
        OrderStatus.cancelled: byStatus.integer('cancelled'),
      },
      invoicesIssued: json.integer('invoicesIssued'),
      amountInvoiced: json.money('amountInvoiced'),
      deposits: json.integer('deposits'),
      amountDeposited: json.money('amountDeposited'),
      amountPaidFromWallets: json.money('amountPaidFromWallets'),
      newTeachers: json.integer('newTeachers'),
      activeTeachers: json.integer('activeTeachers'),
      owedNow: json.money('owedNow'),
      overdueNow: json.money('overdueNow'),
      heldInWalletsNow: json.money('heldInWalletsNow'),
    );
  }

  static SalesReport salesFromJson(Object? raw) {
    final json = JsonMap.of(raw);
    return SalesReport(
      from: json.day('from'),
      to: json.day('to'),
      groupBy: SalesGroupBy.fromApi(json.stringOrNull('groupBy')),
      orders: json.integer('orders'),
      copies: json.integer('copies'),
      amount: json.money('amount'),
      rows: json.list('rows', (raw) {
        final row = JsonMap.of(raw);
        return SalesRow(
          key: row.string('key'),
          label: row.string('label'),
          orders: row.integer('orders'),
          copies: row.integer('copies'),
          amount: row.money('amount'),
        );
      }),
    );
  }
}
