import 'package:equatable/equatable.dart';
import 'package:medstore_core/medstore_core.dart';

/// What a notification is about (the server's `NotificationType`).
enum NotificationKind {
  orderPlacedForYou('OrderPlacedForYou'),
  orderStatusChanged('OrderStatusChanged'),
  invoiceIssued('InvoiceIssued'),
  depositRecorded('DepositRecorded'),
  productCreated('ProductCreated'),

  /// A type added on the server later: shown with the server's own text.
  other('');

  const NotificationKind(this.apiName);

  final String apiName;

  static NotificationKind fromApi(String? value) =>
      values.firstWhere((kind) => kind.apiName == value, orElse: () => other);
}

/// Something the teacher is told about (`NotificationDto`).
final class TeacherNotification extends Equatable {
  const TeacherNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.data = const {},
    this.link,
    this.readAt,
  });

  final String id;
  final NotificationKind type;

  /// The server's French text, used when the app cannot rebuild it from [type] and [data].
  final String title;
  final String message;

  /// The values the text is made of: `number`, `status`, `name`…
  final Map<String, String> data;

  /// Where it leads: `orders/{id}`, `products/{id}`, `invoices/{id}`, `wallet`.
  final String? link;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  TeacherNotification asRead(DateTime at) => TeacherNotification(
    id: id,
    type: type,
    title: title,
    message: message,
    createdAt: createdAt,
    data: data,
    link: link,
    readAt: readAt ?? at,
  );

  @override
  List<Object?> get props => [id, type, title, message, data, link, createdAt, readAt];
}

final class NotificationFilter extends Equatable {
  const NotificationFilter({this.unreadOnly = false});

  final bool unreadOnly;

  @override
  List<Object?> get props => [unreadOnly];
}

/// `/api/notifications` and the live hub's `notification` event.
abstract interface class NotificationRepository {
  Future<Result<PagedList<TeacherNotification>>> list(NotificationFilter filter, {int page = 1});

  Future<Result<int>> unreadCount();

  Future<Result<void>> markRead(String id);

  Future<Result<void>> markAllRead();

  /// A new notification, pushed by the server while the app is connected.
  Stream<TeacherNotification> get arrivals;
}
