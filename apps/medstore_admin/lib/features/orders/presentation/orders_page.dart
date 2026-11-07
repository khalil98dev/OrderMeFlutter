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
import '../domain/admin_orders.dart';

typedef OrdersCubit = PagedListCubit<OrderSummary, OrderFilter>;

/// Every order, newest first: by status, teacher, number and placing date; new order on a teacher's
/// behalf; a row opens the order.
///
/// Expects an [OrdersCubit] and [SearchTeachers] above it.
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final cubit = context.read<OrdersCubit>();
    final total = context.select<OrdersCubit, int>((cubit) => cubit.state.totalCount);
    final filter = context.select<OrdersCubit, OrderFilter>((cubit) => cubit.state.filter);

    return AdminPage(
      title: strings.navOrders,
      subtitle: total > 0 ? strings.ordersCount(total) : null,
      actions: [
        AppButton(
          label: strings.newOrder,
          icon: AppIcons.add,
          onPressed: () => _open(context, '/orders/new'),
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
                width: 200,
                child: AppSelectField<OrderStatus>(
                  label: strings.colStatus,
                  options: {
                    for (final status in OrderStatus.values) status: orderStatusText(strings, status),
                  },
                  value: filter.status,
                  allowNone: true,
                  onChanged: (status) => cubit.setFilter(filter.copyWith(status: () => status)),
                ),
              ),
              SizedBox(
                width: 260,
                child: TeacherFilterField(
                  search: context.read<SearchTeachers>(),
                  teacherName: filter.clientName,
                  onChanged: (teacher) => cubit.setFilter(filter.copyWith(client: () => teacher)),
                ),
              ),
              SizedBox(
                width: 160,
                child: AppSearchField(
                  placeholder: strings.searchOrderNumber,
                  onChanged: (text) =>
                      cubit.setFilter(filter.copyWith(number: () => int.tryParse(text.trim()))),
                ),
              ),
              PeriodBar(
                from: filter.from,
                to: filter.to,
                width: 170,
                onChanged: (from, to) => cubit.setFilter(filter.copyWith(from: () => from, to: () => to)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: PagedTable<OrderSummary, OrderFilter>(
              columns: [
                AppTableColumn(strings.colNumber, width: 80),
                AppTableColumn(strings.colTeacher, flex: 3),
                AppTableColumn(strings.colDate, width: 150),
                AppTableColumn(strings.colLines, width: 70),
                AppTableColumn(strings.colCopies, width: 90),
                AppTableColumn(strings.colStatus, width: 140),
                AppTableColumn.amount(strings.colTotal),
              ],
              onTap: (order) => _open(context, '/orders/${order.id}'),
              empty: AppEmptyState(
                icon: AppIcons.cart,
                title: strings.noOrdersTitle,
                message: strings.noOrdersMessage,
              ),
              cells: (context, order) => [
                Text('${order.number}'),
                Text(order.clientName ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(AppDateFormat.dateTime(order.placedAt, locale)),
                Text('${order.lineCount}'),
                Text('${order.totalQuantity}'),
                AppBadge(label: orderStatusText(strings, order.status), tone: orderStatusTone(order.status)),
                AppMoney(order.total, style: AppTypography.row),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Opens a page; when it comes back with a message (saved), shows it and reloads the list.
  static Future<void> _open(BuildContext context, String path) async {
    final cubit = context.read<OrdersCubit>();
    final message = await context.push<String>(path);
    if (!context.mounted) return;
    if (message != null) showAppToast(context, message, tone: AppTone.success);
    await cubit.load(); // a status may have changed on the detail page
  }
}
