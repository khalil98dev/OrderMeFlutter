import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/l10n/labels.dart';
import '../../../app/widgets/choice_chips.dart';
import '../../../app/widgets/soft_card.dart';
import '../domain/notification.dart';
import 'unread_cubit.dart';

typedef NotificationsCubit = PagedListCubit<TeacherNotification, NotificationFilter>;

/// The teacher's notifications, newest first. Unread ones carry a garnet dot; tapping one marks it
/// read and opens what it is about (an order, a product). A notification pushed live appears at once.
///
/// Expects a [NotificationsCubit] (the route) and the app's [NotificationRepository] and [UnreadCubit].
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const _loadMoreDistance = 400.0;

  StreamSubscription<TeacherNotification>? _live;

  /// Marked read on this screen since the last load, so the dot goes away before the server answers.
  final _readHere = <String>{};

  @override
  void initState() {
    super.initState();
    final cubit = context.read<NotificationsCubit>();
    _live = context.read<NotificationRepository>().arrivals.listen((_) => cubit.load());
  }

  @override
  void dispose() {
    _live?.cancel();
    super.dispose();
  }

  Future<void> _open(TeacherNotification notification) async {
    final repository = context.read<NotificationRepository>();
    final unread = context.read<UnreadCubit>();
    if (!notification.isRead && _readHere.add(notification.id)) {
      setState(() {});
      unread.read();
      unawaited(repository.markRead(notification.id));
    }
    final link = notification.link;
    // Only the screens this app has: orders and products. Invoices and the wallet are on the desktop.
    if (link != null && (link.startsWith('orders/') || link.startsWith('products/'))) {
      context.go('/$link');
    }
  }

  Future<void> _markAll() async {
    final cubit = context.read<NotificationsCubit>();
    final unread = context.read<UnreadCubit>();
    final result = await context.read<NotificationRepository>().markAllRead();
    if (result.isOk) {
      unread.allRead();
      _readHere.clear();
      await cubit.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<NotificationsCubit>();
    final state = context.watch<NotificationsCubit>().state;
    final unread = context.watch<UnreadCubit>().state;

    return CupertinoPageScaffold(
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.axis == Axis.vertical && scroll.metrics.extentAfter < _loadMoreDistance) {
            cubit.loadMore();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: Text(strings.navNotifications),
              border: null,
              trailing: unread == 0
                  ? null
                  : CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _markAll,
                      child: Text(strings.markAllRead, style: AppTypography.subheadline),
                    ),
            ),
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                _readHere.clear();
                await Future.wait([cubit.load(), context.read<UnreadCubit>().refresh()]);
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              sliver: SliverToBoxAdapter(
                child: ChoiceChips<bool>(
                  options: {false: strings.filterAll, true: strings.unreadOnly},
                  selected: state.filter.unreadOnly,
                  onChanged: (value) => cubit.setFilter(NotificationFilter(unreadOnly: value)),
                ),
              ),
            ),
            if (state.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppLoadView(
                  isLoading: state.isLoading || state.page == 0,
                  hasData: false,
                  failure: state.failure,
                  onRetry: cubit.load,
                  builder: (_) => const SizedBox.shrink(),
                  empty: AppEmptyState(
                    icon: AppIcons.notifications,
                    title: strings.noNotificationsTitle,
                    message: strings.noNotificationsMessage,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverList.separated(
                  itemCount: state.items.length + (state.hasMore ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    if (index == state.items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: CupertinoActivityIndicator(),
                      );
                    }
                    final item = state.items[index];
                    return NotificationTile(
                      notification: item,
                      isRead: item.isRead || _readHere.contains(item.id),
                      onTap: () => _open(item),
                    );
                  },
                ),
              ),
            const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, required this.isRead, required this.onTap});

  final TeacherNotification notification;
  final bool isRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final text = notificationText(strings, notification);
    final tone = notificationTone(notification).resolve(context);

    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: tone.background, shape: BoxShape.circle),
            child: Icon(notificationIcon(notification), size: 22, color: tone.foreground),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text.title,
                  style: AppTypography.subheadline.copyWith(
                    fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                    color: AppColors.textPrimary.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text.message,
                  style: AppTypography.footnote.copyWith(color: AppColors.textSecondary.resolveFrom(context)),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  AppDateFormat.dateTime(notification.createdAt.toLocal(), locale),
                  style: AppTypography.caption.copyWith(color: AppColors.textTertiary.resolveFrom(context)),
                ),
              ],
            ),
          ),
          AnimatedOpacity(
            opacity: isRead ? 0 : 1,
            duration: AppDurations.of(context, AppDurations.micro),
            child: Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(color: AppColors.accent.resolveFrom(context), shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
