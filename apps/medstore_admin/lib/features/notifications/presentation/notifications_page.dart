import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/shell/admin_page.dart';
import '../domain/notification.dart';

typedef NotificationsCubit = PagedListCubit<AppNotification, NotificationFilter>;

/// The team's notifications, newest first. A new one pushed by the server reloads the list.
///
/// Expects a [NotificationsCubit], [NotificationRepository], [MarkNotificationRead] and
/// [MarkAllNotificationsRead] above it; the route provides them.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const _loadMoreDistance = 400.0;

  StreamSubscription<void>? _live;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<NotificationsCubit>();
    _live = context.read<NotificationRepository>().created.listen((_) => cubit.load());
  }

  @override
  void dispose() {
    _live?.cancel();
    super.dispose();
  }

  Future<void> _open(AppNotification notification) async {
    if (notification.isRead) return;
    final cubit = context.read<NotificationsCubit>();
    final result = await context.read<MarkNotificationRead>()(notification.id);
    if (result.isOk) await cubit.load();
  }

  Future<void> _markAll() async {
    final cubit = context.read<NotificationsCubit>();
    final result = await context.read<MarkAllNotificationsRead>()(const NoParams());
    if (result.isOk) await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final cubit = context.read<NotificationsCubit>();
    final state = context.watch<NotificationsCubit>().state;

    return AdminPage(
      title: strings.navNotifications,
      actions: [
        AppButton(label: strings.markAllRead, icon: CupertinoIcons.checkmark_alt, onPressed: _markAll),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppCheckbox(
              label: strings.unreadOnly,
              value: state.filter.unreadOnly,
              onChanged: (value) => cubit.setFilter(NotificationFilter(unreadOnly: value)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: AppLoadView(
              isLoading: state.isLoading || state.page == 0,
              hasData: state.items.isNotEmpty,
              failure: state.failure,
              onRetry: cubit.load,
              empty: AppEmptyState(
                icon: CupertinoIcons.bell,
                title: strings.noNotificationsTitle,
                message: strings.noNotificationsMessage,
              ),
              builder: (context) => NotificationListener<ScrollNotification>(
                onNotification: (scroll) {
                  if (scroll.metrics.extentAfter < _loadMoreDistance) cubit.loadMore();
                  return false;
                },
                child: ListView.separated(
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return AppListTile(
                      leading: Icon(item.isRead ? CupertinoIcons.bell : CupertinoIcons.bell_fill),
                      title: item.title,
                      subtitle: [
                        if (item.message != null) item.message!,
                        AppDateFormat.dateTime(item.createdAt.toLocal(), locale),
                      ].join('\n'),
                      onTap: () => _open(item),
                      showChevron: false,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
