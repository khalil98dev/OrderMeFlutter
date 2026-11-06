import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_admin/features/notifications/data/notification_repository_impl.dart';
import 'package:medstore_admin/features/notifications/presentation/open_notification.dart';

/// A `NotificationDto` as the API sends it.
Map<String, Object?> _dto({String? readAt}) => {
  'id': '3f2a',
  'type': 'OrderPlaced',
  'title': 'Nouvelle commande n° 12',
  'message': 'prof.amina a passé une commande de 4 500,00 DA.',
  'data': {'orderId': 'o1', 'number': '12'},
  'link': 'orders/o1',
  'createdAt': '2026-11-06T10:15:00+00:00',
  'readAt': readAt,
};

void main() {
  test('reads a NotificationDto: unread while readAt is null', () {
    final notification = NotificationRepositoryImpl.fromJson(_dto());

    expect(notification.id, '3f2a');
    expect(notification.title, 'Nouvelle commande n° 12');
    expect(notification.type, 'OrderPlaced');
    expect(notification.isRead, isFalse);
  });

  test('a readAt date means it was read', () {
    expect(NotificationRepositoryImpl.fromJson(_dto(readAt: '2026-11-06T11:00:00+00:00')).isRead, isTrue);
  });

  test('an order notification leads to that order', () {
    final notification = NotificationRepositoryImpl.fromJson(_dto());

    expect(notification.orderId, 'o1');
    expect(notificationRoute(notification), '/orders/o1');
  });

  test('other links lead to their section, unknown ones nowhere', () {
    final invoice = NotificationRepositoryImpl.fromJson({..._dto(), 'link': 'invoices/i9'});
    final wallet = NotificationRepositoryImpl.fromJson({..._dto(), 'link': 'wallet'});
    final none = NotificationRepositoryImpl.fromJson({..._dto(), 'link': null});

    expect(invoice.orderId, isNull);
    expect(notificationRoute(invoice), '/invoices/i9');
    expect(notificationRoute(wallet), '/wallet');
    expect(notificationRoute(none), isNull);
  });
}
