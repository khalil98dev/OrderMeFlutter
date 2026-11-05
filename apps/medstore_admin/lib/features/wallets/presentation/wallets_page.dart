import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/shell/admin_page.dart';
import '../../../app/widgets/paged_table.dart';
import '../domain/wallet.dart';

typedef WalletsCubit = PagedListCubit<Wallet, WalletFilter>;

/// Every teacher's wallet, biggest balance first. A row opens the wallet's ledger.
///
/// Expects a [WalletsCubit] above it.
class WalletsPage extends StatelessWidget {
  const WalletsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final cubit = context.read<WalletsCubit>();
    final total = context.select<WalletsCubit, int>((cubit) => cubit.state.totalCount);

    return AdminPage(
      title: strings.navWallet,
      subtitle: total > 0 ? strings.walletsCount(total) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSearchField(
            placeholder: strings.searchTeachers,
            onChanged: (text) => cubit.setFilter(WalletFilter(search: text)),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: PagedTable<Wallet, WalletFilter>(
              columns: [
                AppTableColumn(strings.colTeacher, flex: 3),
                AppTableColumn(strings.lastMovement, width: 170),
                AppTableColumn.amount(strings.totalDeposited, width: 150),
                AppTableColumn.amount(strings.balance, width: 150),
              ],
              onTap: (wallet) async {
                await context.push('/wallet/${wallet.clientId}');
                await cubit.load(); // the balance may have changed
              },
              empty: AppEmptyState(
                icon: CupertinoIcons.money_dollar_circle,
                title: strings.noWalletsTitle,
                message: strings.noWalletsMessage,
              ),
              cells: (context, wallet) => [
                Row(
                  children: [
                    AppAvatar(name: wallet.clientName ?? '?', size: 32),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(wallet.clientName ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                Text(
                  wallet.lastMovementAt == null
                      ? '—'
                      : AppDateFormat.dateTime(wallet.lastMovementAt!, locale),
                ),
                AppMoney(wallet.totalDeposited, style: AppTypography.subheadline),
                AppMoney(
                  wallet.balance,
                  style: AppTypography.headline,
                  tone: wallet.balance > 0 ? AppTone.success : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
