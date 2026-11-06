import 'package:flutter/cupertino.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../features/notifications/domain/notification.dart';

// The words, tones and icons of the domain's values, in one place so every screen says them the same way.

String orderStatusText(AppStrings s, OrderStatus status) => switch (status) {
  OrderStatus.pending => s.orderStatusPending,
  OrderStatus.inPreparation => s.orderStatusInPreparation,
  OrderStatus.ready => s.orderStatusReady,
  OrderStatus.delivered => s.orderStatusDelivered,
  OrderStatus.cancelled => s.orderStatusCancelled,
};

AppTone orderStatusTone(OrderStatus status) => switch (status) {
  OrderStatus.pending => AppTone.warning,
  OrderStatus.inPreparation => AppTone.info,
  OrderStatus.ready => AppTone.brand,
  OrderStatus.delivered => AppTone.success,
  OrderStatus.cancelled => AppTone.neutral,
};

IconData orderStatusIcon(OrderStatus status) => switch (status) {
  OrderStatus.pending => CupertinoIcons.clock,
  OrderStatus.inPreparation => CupertinoIcons.hammer,
  OrderStatus.ready => CupertinoIcons.bag,
  OrderStatus.delivered => CupertinoIcons.checkmark_seal,
  OrderStatus.cancelled => CupertinoIcons.xmark_circle,
};

/// The notification's title and message in the app's language, rebuilt from its type and data.
/// The server's French text is the fallback for anything this version does not know.
({String title, String message}) notificationText(AppStrings s, TeacherNotification n) {
  final number = n.data['number'] ?? '';
  return switch (n.type) {
    NotificationKind.orderPlacedForYou => (
      title: s.notifOrderPlacedForYouTitle(number),
      message: s.notifOrderPlacedForYouMessage,
    ),
    NotificationKind.orderStatusChanged => switch (OrderStatus.fromApi(n.data['status'])) {
      OrderStatus.inPreparation => (
        title: s.notifOrderPreparingTitle(number),
        message: s.notifOrderPreparingMessage,
      ),
      OrderStatus.ready => (title: s.notifOrderReadyTitle(number), message: s.readyPickupHint),
      OrderStatus.delivered => (
        title: s.notifOrderDeliveredTitle(number),
        message: s.notifOrderDeliveredMessage,
      ),
      OrderStatus.cancelled => (
        title: s.notifOrderCancelledTitle(number),
        message: s.notifOrderCancelledMessage,
      ),
      OrderStatus.pending => (title: n.title, message: n.message),
    },
    NotificationKind.invoiceIssued => (title: s.notifInvoiceTitle(number), message: s.notifInvoiceMessage),
    NotificationKind.depositRecorded => (title: s.notifDepositTitle, message: s.notifDepositMessage),
    NotificationKind.productCreated => (
      title: s.notifProductTitle,
      message: s.notifProductMessage(n.data['name'] ?? ''),
    ),
    NotificationKind.other => (title: n.title, message: n.message),
  };
}

IconData notificationIcon(TeacherNotification n) => switch (n.type) {
  NotificationKind.orderPlacedForYou => CupertinoIcons.cart_fill,
  NotificationKind.orderStatusChanged => orderStatusIcon(OrderStatus.fromApi(n.data['status'])),
  NotificationKind.invoiceIssued => CupertinoIcons.doc_text_fill,
  NotificationKind.depositRecorded => CupertinoIcons.money_dollar_circle_fill,
  NotificationKind.productCreated => CupertinoIcons.book_fill,
  NotificationKind.other => CupertinoIcons.bell_fill,
};

AppTone notificationTone(TeacherNotification n) => switch (n.type) {
  NotificationKind.orderStatusChanged => orderStatusTone(OrderStatus.fromApi(n.data['status'])),
  NotificationKind.depositRecorded => AppTone.success,
  NotificationKind.invoiceIssued => AppTone.info,
  _ => AppTone.brand,
};
