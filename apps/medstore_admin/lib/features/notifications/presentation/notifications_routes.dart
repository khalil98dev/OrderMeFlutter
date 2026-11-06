import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/injection.dart';
import '../domain/notification.dart';
import 'notifications_page.dart';

/// `/notifications`.
GoRoute notificationsRoute() => GoRoute(
  path: '/notifications',
  pageBuilder: (_, _) => NoTransitionPage(
    child: MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: sl<NotificationRepository>()),
        RepositoryProvider.value(value: sl<MarkNotificationRead>()),
        RepositoryProvider.value(value: sl<MarkAllNotificationsRead>()),
      ],
      child: BlocProvider(
        create: (_) => NotificationsCubit(
          (filter, page) => sl<ListNotifications>()(filter, page: page),
          filter: const NotificationFilter(),
        )..load(),
        child: const NotificationsPage(),
      ),
    ),
  ),
);
