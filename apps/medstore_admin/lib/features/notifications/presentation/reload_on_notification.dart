import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/notification.dart';

/// Calls [onArrival] for each notification the server pushes that [when] accepts, while [child] is
/// on screen: the orders list reloads on an order's news, an order's page on its own.
///
/// Expects the [NotificationRepository] above it (the app root provides it).
class ReloadOnNotification extends StatefulWidget {
  const ReloadOnNotification({super.key, required this.when, required this.onArrival, required this.child});

  final bool Function(AppNotification notification) when;

  /// Receives a context below this widget, so it can read the page's Cubit.
  final void Function(BuildContext context) onArrival;
  final Widget child;

  @override
  State<ReloadOnNotification> createState() => _ReloadOnNotificationState();
}

class _ReloadOnNotificationState extends State<ReloadOnNotification> {
  StreamSubscription<AppNotification>? _live;

  @override
  void initState() {
    super.initState();
    _live = context.read<NotificationRepository>().arrivals.listen((notification) {
      if (mounted && widget.when(notification)) widget.onArrival(context);
    });
  }

  @override
  void dispose() {
    _live?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
