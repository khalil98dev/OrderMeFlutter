import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/shell/admin_page.dart';
import '../domain/notification.dart';
import 'open_notification.dart';
import 'reload_on_notification.dart';
import 'unread_cubit.dart';

typedef NotificationsCubit = PagedListCubit<AppNotification, NotificationFilter>;

/// The team's notifications, newest first. A new one pushed by the server reloads the list; clicking
/// one marks it read and opens what it is about (an order opens its detail page).
///
/// Expects a [NotificationsCubit] and [MarkAllNotificationsRead] above it (the route provides them),
/// and the [NotificationRepository] and [UnreadCubit] (the app root provides them).
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const _loadMoreDistance = 400.0;

  @override
  Widget build(BuildContext context) {
    return ReloadOnNotification(
      when: (_) => true,
      onArrival: (context) => unawaited(context.read<NotificationsCubit>().load()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  void _open(BuildContext context, AppNotification notification) {
    final cubit = context.read<NotificationsCubit>();
    openNotification(context, notification);
    // Shows it read when coming back (this page stays alive in its branch).
    if (!notification.isRead) unawaited(cubit.load());
  }

  Future<void> _markAll(BuildContext context) async {
    final cubit = context.read<NotificationsCubit>();
    final unread = context.read<UnreadCubit>();
    final result = await context.read<MarkAllNotificationsRead>()(const NoParams());
    if (!result.isOk) return;
    unread.allRead();
    await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<NotificationsCubit>();
    final state = context.watch<NotificationsCubit>().state;
    final unread = context.watch<UnreadCubit>().state;

    return AdminPage(
      title: strings.navNotifications,
      actions: [
        AppButton(
          label: strings.markAllRead,
          icon: CupertinoIcons.checkmark_alt,
          onPressed: unread == 0 ? null : () => _markAll(context),
        ),
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
                  if (scroll.metrics.extentAfter < NotificationsPage._loadMoreDistance) cubit.loadMore();
                  return false;
                },
                child: ListView.separated(
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return _AppearIn(
                      key: ValueKey(item.id),
                      // The first screenful cascades in; rows loaded later just appear.
                      delay: Duration(milliseconds: 30 * index.clamp(0, 10)),
                      child: _NotificationTile(notification: item, onTap: () => _open(context, item)),
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

/// One notification: its type's icon, title, message and time, a dot while unread, and "view order"
/// when it leads to one.
class _NotificationTile extends StatefulWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final item = widget.notification;
    final tone = notificationTone(item).resolve(context);
    final opens = notificationRoute(item) != null;
    final unread = !item.isRead;

    return Semantics(
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AppDurations.of(context, AppDurations.micro),
            padding: const EdgeInsets.all(AppSpacing.sm),
            transform: Matrix4.translationValues(0, _hovered ? -1 : 0, 0),
            decoration: BoxDecoration(
              color: unread
                  ? AppColors.brandTint.resolveFrom(context).withValues(alpha: 0.45)
                  : AppColors.surface.resolveFrom(context),
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              border: Border.all(
                color: _hovered
                    ? AppColors.brand.resolveFrom(context).withValues(alpha: 0.4)
                    : AppColors.separator.resolveFrom(context),
                width: _hovered ? 1 : 0.5,
              ),
              boxShadow: [
                if (_hovered) const BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 6)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: tone.background, shape: BoxShape.circle),
                  child: Icon(notificationIcon(item), size: 18, color: tone.foreground),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTypography.subheadline.copyWith(
                          fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.textPrimary.resolveFrom(context),
                        ),
                      ),
                      if (item.message case final message?) ...[
                        const SizedBox(height: 2),
                        Text(
                          message,
                          style: AppTypography.footnote.copyWith(
                            color: AppColors.textSecondary.resolveFrom(context),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxs),
                      Row(
                        children: [
                          Text(
                            AppDateFormat.dateTime(item.createdAt.toLocal(), locale),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary.resolveFrom(context),
                            ),
                          ),
                          if (item.orderId != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              strings.viewOrder,
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.brand.resolveFrom(context),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Column(
                  children: [
                    AnimatedScale(
                      scale: unread ? 1 : 0,
                      duration: AppDurations.of(context, AppDurations.micro),
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppColors.brand.resolveFrom(context),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    if (opens) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Icon(
                        CupertinoIcons.chevron_forward,
                        size: 14,
                        color: AppColors.textTertiary.resolveFrom(context),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fades and slides [child] up into place the first time it is built.
class _AppearIn extends StatelessWidget {
  const _AppearIn({super.key, required this.delay, required this.child});

  final Duration delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = AppDurations.of(context, AppDurations.selection);
    if (duration == Duration.zero) return child;
    final total = duration + delay;
    final start = delay.inMicroseconds / total.inMicroseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}
