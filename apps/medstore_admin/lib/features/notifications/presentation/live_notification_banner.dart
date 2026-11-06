import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Tooltip;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../domain/notification.dart';
import 'open_notification.dart';

/// Shows each notification the server pushes as a card that slides in at the top end of the window,
/// stays a few seconds (longer while the pointer is on it), and opens what it is about when clicked.
///
/// Sits in a `Stack` above the pages. Expects the [NotificationRepository] above it.
class LiveNotificationBanner extends StatefulWidget {
  const LiveNotificationBanner({super.key});

  /// How long a card stays when nobody touches it.
  static const shownFor = Duration(seconds: 6);

  @override
  State<LiveNotificationBanner> createState() => _LiveNotificationBannerState();
}

class _LiveNotificationBannerState extends State<LiveNotificationBanner> {
  StreamSubscription<AppNotification>? _live;
  Timer? _timer;
  AppNotification? _shown;
  var _hovered = false;

  @override
  void initState() {
    super.initState();
    _live = context.read<NotificationRepository>().arrivals.listen(_show);
  }

  @override
  void dispose() {
    _live?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void _show(AppNotification notification) {
    if (!mounted) return;
    setState(() => _shown = notification);
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer(LiveNotificationBanner.shownFor, () {
      if (mounted && !_hovered) setState(() => _shown = null);
    });
  }

  void _dismiss() {
    _timer?.cancel();
    setState(() => _shown = null);
  }

  void _open(AppNotification notification) {
    _dismiss();
    openNotification(context, notification);
  }

  @override
  Widget build(BuildContext context) {
    final shown = _shown;
    return AnimatedSwitcher(
      duration: AppDurations.of(context, AppDurations.selection),
      reverseDuration: AppDurations.of(context, AppDurations.micro),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, -0.6), end: Offset.zero).animate(animation),
          child: child,
        ),
      ),
      child: shown == null
          ? const SizedBox.shrink()
          : MouseRegion(
              key: ValueKey(shown.id),
              onEnter: (_) => _hovered = true,
              onExit: (_) {
                _hovered = false;
                _restartTimer();
              },
              child: _BannerCard(notification: shown, onOpen: () => _open(shown), onClose: _dismiss),
            ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.notification, required this.onOpen, required this.onClose});

  final AppNotification notification;
  final VoidCallback onOpen;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final tone = notificationTone(notification).resolve(context);
    final opens = notificationRoute(notification) != null;

    return Semantics(
      liveRegion: true,
      button: opens,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: opens ? onOpen : null,
        child: MouseRegion(
          cursor: opens ? SystemMouseCursors.click : MouseCursor.defer,
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface.resolveFrom(context),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              border: Border.all(color: AppColors.separator.resolveFrom(context), width: 0.5),
              boxShadow: const [BoxShadow(color: Color(0x29000000), blurRadius: 24, offset: Offset(0, 10))],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PulsingIcon(
                  icon: notificationIcon(notification),
                  foreground: tone.foreground,
                  background: tone.background,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        notification.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headline.copyWith(
                          fontSize: 15,
                          color: AppColors.textPrimary.resolveFrom(context),
                        ),
                      ),
                      if (notification.message case final message?) ...[
                        const SizedBox(height: 2),
                        Text(
                          message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.footnote.copyWith(
                            color: AppColors.textSecondary.resolveFrom(context),
                          ),
                        ),
                      ],
                      if (notification.orderId != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          strings.viewOrder,
                          style: AppTypography.footnote.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.brand.resolveFrom(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tooltip(
                  message: strings.close,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size.square(24),
                    onPressed: onClose,
                    child: Icon(
                      AppIcons.close,
                      size: 14,
                      color: AppColors.textSecondary.resolveFrom(context),
                      semanticLabel: strings.close,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The type's icon in a tinted circle, with a ring that spreads out once when the card appears.
class _PulsingIcon extends StatelessWidget {
  const _PulsingIcon({required this.icon, required this.foreground, required this.background});

  final IconData icon;
  final Color foreground;
  final Color background;

  static const _size = 40.0;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppDurations.of(context, const Duration(milliseconds: 900)),
      curve: Curves.easeOut,
      builder: (context, t, child) => Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (t < 1)
            Container(
              width: _size * (1 + 0.6 * t),
              height: _size * (1 + 0.6 * t),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: foreground.withValues(alpha: 0.5 * (1 - t)), width: 2),
              ),
            ),
          child!,
        ],
      ),
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: foreground),
      ),
    );
  }
}
