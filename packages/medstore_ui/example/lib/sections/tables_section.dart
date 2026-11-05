import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../widgets/gallery_section.dart';

/// Tables and facts: the admin's lists and detail panels.
class TablesSection extends StatelessWidget {
  const TablesSection({super.key});

  static const _orders = [
    (1042, 'Amina Benali', 3, 12500.0, AppTone.warning),
    (1041, 'Karim Ait Said', 1, 2400.0, AppTone.info),
    (1040, 'Yacine Haddad', 5, 31800.0, AppTone.success),
  ];

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final statuses = {
      AppTone.warning: strings.orderStatusPending,
      AppTone.info: strings.orderStatusInPreparation,
      AppTone.success: strings.orderStatusReady,
    };
    return GallerySection(
      title: tr(context, 'Tableaux', 'الجداول'),
      components: 'AppTable · AppTableColumn · AppInfoRow · AppPageHeader(onBack) · AppDateFormat',
      children: [
        SizedBox(
          width: 640,
          height: 260,
          child: AppTable(
            columns: [
              AppTableColumn(strings.colNumber, width: 70),
              AppTableColumn(strings.colTeacher, flex: 2),
              AppTableColumn(strings.colLines, width: 60),
              AppTableColumn(strings.colStatus, width: 130),
              AppTableColumn.amount(strings.colTotal),
            ],
            rowCount: _orders.length,
            hasMore: true,
            onRowTap: (_) {},
            cells: (context, index) {
              final (number, name, lines, total, tone) = _orders[index];
              return [
                Text('$number'),
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('$lines'),
                AppBadge(label: statuses[tone]!, tone: tone),
                AppMoney(total, style: AppTypography.subheadline),
              ];
            },
          ),
        ),
        Demo(
          label: 'AppInfoRow',
          child: Column(
            children: [
              AppInfoRow(
                label: strings.issueDate,
                value: AppDateFormat.day(DateTime(2026, 11, 4), _locale(context)),
              ),
              AppInfoRow(label: strings.fieldPhone),
              AppInfoRow(
                label: strings.amountPaid,
                child: const AppMoney(5000, style: AppTypography.subheadline),
              ),
              AppInfoRow(
                label: strings.amountDue,
                emphasized: true,
                child: const AppMoney(7500, style: AppTypography.headline, tone: AppTone.danger),
              ),
            ],
          ),
        ),
        Demo(
          label: 'AppPageHeader(onBack)',
          width: 420,
          child: AppPageHeader(
            title: strings.orderNumber(1042),
            subtitle: 'Amina Benali',
            onBack: () {},
            actions: [AppButton(label: strings.reviseOrder, size: AppButtonSize.small, onPressed: () {})],
          ),
        ),
      ],
    );
  }

  static Locale _locale(BuildContext context) => Localizations.localeOf(context);
}
