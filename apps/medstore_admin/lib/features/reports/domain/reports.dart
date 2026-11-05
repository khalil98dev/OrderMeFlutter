import 'package:equatable/equatable.dart';
import 'package:medstore_core/medstore_core.dart';

/// The period at a glance (from and to: local days, both included) and today's position.
final class SummaryReport extends Equatable {
  const SummaryReport({
    required this.from,
    required this.to,
    required this.ordersPlaced,
    required this.copiesOrdered,
    required this.amountOrdered,
    required this.ordersByStatus,
    required this.invoicesIssued,
    required this.amountInvoiced,
    required this.deposits,
    required this.amountDeposited,
    required this.amountPaidFromWallets,
    required this.newTeachers,
    required this.activeTeachers,
    required this.owedNow,
    required this.overdueNow,
    required this.heldInWalletsNow,
  });

  final DateTime from;
  final DateTime to;
  final int ordersPlaced;
  final int copiesOrdered;
  final num amountOrdered;
  final Map<OrderStatus, int> ordersByStatus;
  final int invoicesIssued;
  final num amountInvoiced;
  final int deposits;
  final num amountDeposited;
  final num amountPaidFromWallets;
  final int newTeachers;
  final int activeTeachers;
  final num owedNow;
  final num overdueNow;
  final num heldInWalletsNow;

  @override
  List<Object?> get props => [from, to, ordersPlaced, amountOrdered, ordersByStatus, amountInvoiced, owedNow];
}

enum SalesGroupBy {
  product('Product'),
  client('Client'),
  school('School'),
  wilaya('Wilaya'),
  month('Month');

  const SalesGroupBy(this.apiName);

  final String apiName;

  static SalesGroupBy fromApi(String? value) =>
      values.firstWhere((group) => group.apiName == value, orElse: () => product);
}

final class SalesRow extends Equatable {
  const SalesRow({
    required this.key,
    required this.label,
    required this.orders,
    required this.copies,
    required this.amount,
  });

  final String key;
  final String label;
  final int orders;
  final int copies;
  final num amount;

  @override
  List<Object?> get props => [key, label, orders, copies, amount];
}

/// What was ordered in a period, grouped; cancelled orders left out.
final class SalesReport extends Equatable {
  const SalesReport({
    required this.from,
    required this.to,
    required this.groupBy,
    required this.rows,
    required this.orders,
    required this.copies,
    required this.amount,
  });

  final DateTime from;
  final DateTime to;
  final SalesGroupBy groupBy;
  final List<SalesRow> rows;
  final int orders;
  final int copies;
  final num amount;

  @override
  List<Object?> get props => [from, to, groupBy, rows, orders, copies, amount];
}

final class ReportPeriod extends Equatable {
  const ReportPeriod({this.from, this.to});

  /// The month so far: what the dashboard opens on.
  factory ReportPeriod.thisMonth(DateTime today) =>
      ReportPeriod(from: DateTime(today.year, today.month), to: DateTime(today.year, today.month, today.day));

  /// Null: the API's default.
  final DateTime? from;
  final DateTime? to;

  @override
  List<Object?> get props => [from, to];
}

/// `/api/admin/reports`.
abstract interface class ReportRepository {
  Future<Result<SummaryReport>> summary(ReportPeriod period);

  Future<Result<SalesReport>> sales(ReportPeriod period, SalesGroupBy groupBy);
}

class GetSummaryReport implements UseCase<SummaryReport, ReportPeriod> {
  const GetSummaryReport(this._repository);

  final ReportRepository _repository;

  @override
  Future<Result<SummaryReport>> call(ReportPeriod period) => _repository.summary(period);
}

final class SalesParams {
  const SalesParams(this.period, this.groupBy);

  final ReportPeriod period;
  final SalesGroupBy groupBy;
}

class GetSalesReport implements UseCase<SalesReport, SalesParams> {
  const GetSalesReport(this._repository);

  final ReportRepository _repository;

  @override
  Future<Result<SalesReport>> call(SalesParams params) => _repository.sales(params.period, params.groupBy);
}
