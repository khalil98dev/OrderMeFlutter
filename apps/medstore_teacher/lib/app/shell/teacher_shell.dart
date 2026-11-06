import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../features/cart/cart_bar.dart';
import '../../features/notifications/domain/notification.dart';
import '../../features/notifications/presentation/unread_cubit.dart';
import '../l10n/labels.dart';
import '../router/teacher_router.dart';
import '../widgets/count_badge.dart';

/// The signed-in frame: the selected tab above an iOS tab bar (notifications carry their unread
/// count), the floating cart over the products tab, and a toast for each live notification.
class TeacherShell extends StatefulWidget {
  const TeacherShell({super.key, required this.shell, required this.location});

  final StatefulNavigationShell shell;

  /// The current path, to lift the cart above a product page's own bottom bar.
  final String location;

  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell> with WidgetsBindingObserver {
  /// Height of a product page's add bar, which the cart floats above.
  static const _addBarHeight = 76.0;

  StreamSubscription<TeacherNotification>? _live;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _live = context.read<NotificationRepository>().arrivals.listen(_announce);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _live?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from the background: notifications may have arrived while the hub was asleep.
    if (state == AppLifecycleState.resumed) unawaited(context.read<UnreadCubit>().refresh());
  }

  void _announce(TeacherNotification notification) {
    if (!mounted) return;
    final text = notificationText(AppStrings.of(context), notification);
    showAppToast(
      context,
      text.title,
      tone: notificationTone(notification),
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final shell = widget.shell;
    final unread = context.watch<UnreadCubit>().state;
    final onProducts = shell.currentIndex == 0;
    final onProductPage = widget.location.startsWith('/products/');

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(child: shell),
              CupertinoTabBar(
                currentIndex: shell.currentIndex,
                activeColor: AppColors.accent.resolveFrom(context),
                height: 56,
                // Tapping the current tab again goes back to its first page.
                onTap: (index) => shell.goBranch(index, initialLocation: index == shell.currentIndex),
                items: [
                  for (final (index, tab) in teacherTabs.indexed)
                    BottomNavigationBarItem(
                      icon: CountBadge(count: index == 2 ? unread : 0, child: Icon(tab.icon)),
                      activeIcon: CountBadge(count: index == 2 ? unread : 0, child: Icon(tab.activeIcon)),
                      label: tab.label(strings),
                    ),
                ],
              ),
            ],
          ),
          if (onProducts)
            PositionedDirectional(
              start: AppSpacing.md,
              end: AppSpacing.md,
              bottom:
                  MediaQuery.paddingOf(context).bottom +
                  56 +
                  AppSpacing.sm +
                  (onProductPage ? _addBarHeight : 0),
              child: const Align(alignment: AlignmentDirectional.centerEnd, child: CartBar()),
            ),
        ],
      ),
    );
  }
}
