import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../../app/di/injection.dart';
import '../domain/wallet.dart';
import '../domain/wallet_repository.dart';
import 'wallet_page.dart';
import 'wallets_page.dart';

/// `/wallet` (every balance) and `/wallet/:clientId` (one teacher's ledger).
GoRoute walletsRoute() => GoRoute(
  path: '/wallet',
  pageBuilder: (_, _) => NoTransitionPage(
    child: BlocProvider(
      create: (_) =>
          WalletsCubit((filter, page) => sl<ListWallets>()(filter, page: page), filter: const WalletFilter())
            ..load(),
      child: const WalletsPage(),
    ),
  ),
  routes: [
    GoRoute(
      path: ':clientId',
      builder: (_, state) {
        final clientId = state.pathParameters['clientId']!;
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: sl<RecordDeposit>()),
            RepositoryProvider.value(value: sl<RecordWithdrawal>()),
            RepositoryProvider.value(value: sl<SettleWallet>()),
            RepositoryProvider.value(value: sl<VoidTransaction>()),
            RepositoryProvider.value(value: sl<DownloadReceipt>()),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => LoadCubit<Wallet>(() => sl<GetWallet>()(clientId))..load()),
              BlocProvider(
                create: (_) => TransactionsCubit(
                  (filter, page) => sl<ListTransactions>()(filter, page: page),
                  filter: TransactionFilter(clientId: clientId),
                )..load(),
              ),
            ],
            child: WalletPage(clientId: clientId),
          ),
        );
      },
    ),
  ],
);
