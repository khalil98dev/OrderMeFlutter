import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../domain/notification.dart';
import 'unread_cubit.dart';

/// The page a notification leads to, from its `link`: an order, an invoice, the wallets, the
/// products. Null when it leads nowhere this app shows.
String? notificationRoute(AppNotification notification) => switch (notification.link?.split('/')) {
  ['orders', final id] when id.isNotEmpty => '/orders/$id',
  ['invoices', final id] when id.isNotEmpty => '/invoices/$id',
  ['wallet', ...] => '/wallet',
  ['products', ...] => '/products',
  _ => null,
};

IconData notificationIcon(AppNotification notification) => switch (notification.type) {
  'OrderPlaced' || 'OrderPlacedForYou' => CupertinoIcons.cart_fill_badge_plus,
  'OrderStatusChanged' => CupertinoIcons.cube_box_fill,
  'InvoiceIssued' => CupertinoIcons.doc_text_fill,
  'DepositRecorded' => CupertinoIcons.money_dollar_circle_fill,
  'ProductCreated' => CupertinoIcons.book_fill,
  _ => CupertinoIcons.bell_fill,
};

AppTone notificationTone(AppNotification notification) => switch (notification.type) {
  'OrderPlaced' || 'OrderPlacedForYou' => AppTone.brand,
  'OrderStatusChanged' => AppTone.info,
  'InvoiceIssued' || 'DepositRecorded' => AppTone.success,
  _ => AppTone.neutral,
};

/// Marks [notification] read (in the background: opening never waits on it) and goes where it leads.
///
/// Expects the [NotificationRepository] and the [UnreadCubit] above [context] (the app root provides
/// both). Returns whether it went somewhere.
bool openNotification(BuildContext context, AppNotification notification) {
  if (!notification.isRead) {
    context.read<UnreadCubit>().read();
    unawaited(context.read<NotificationRepository>().markRead(notification.id));
  }
  final route = notificationRoute(notification);
  if (route == null) return false;
  context.go(route);
  return true;
}
