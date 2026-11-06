import 'package:equatable/equatable.dart';
import 'package:medstore_core/medstore_core.dart';

/// An in-app notification for the signed-in team member.
///
/// From `GET /api/notifications?page&pageSize&unreadOnly`, `GET /api/notifications/unread-count`,
/// `POST /api/notifications/{id}/read`, `POST /api/notifications/read-all`, and the hub's live event
/// `notification` (a `NotificationDto`).
final class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.createdAt,
    this.message,
    this.type,
    this.link,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String? message;

  /// The server's `NotificationType` (`OrderPlaced`, `OrderStatusChanged`…), used only to pick an icon.
  final String? type;

  /// Where it leads, relative to the app: `orders/{id}`, `invoices/{id}`, `products/{id}`, `wallet`.
  final String? link;
  final bool isRead;
  final DateTime createdAt;

  /// The order it is about, when it leads to one.
  String? get orderId => switch (link?.split('/')) {
    ['orders', final id] when id.isNotEmpty => id,
    _ => null,
  };

  AppNotification asRead() => AppNotification(
    id: id,
    title: title,
    message: message,
    type: type,
    link: link,
    createdAt: createdAt,
    isRead: true,
  );

  @override
  List<Object?> get props => [id, title, message, type, link, isRead, createdAt];
}

final class NotificationFilter extends Equatable {
  const NotificationFilter({this.unreadOnly = false});

  final bool unreadOnly;

  @override
  List<Object?> get props => [unreadOnly];
}

abstract interface class NotificationRepository {
  Future<Result<PagedList<AppNotification>>> list(NotificationFilter filter, {int page = 1});

  Future<Result<int>> unreadCount();

  Future<Result<void>> markRead(String id);

  Future<Result<void>> markAllRead();

  /// Each notification the server pushes, as it arrives.
  Stream<AppNotification> get arrivals;
}

class ListNotifications {
  const ListNotifications(this._repository);

  final NotificationRepository _repository;

  Future<Result<PagedList<AppNotification>>> call(NotificationFilter filter, {int page = 1}) =>
      _repository.list(filter, page: page);
}

class MarkNotificationRead implements UseCase<void, String> {
  const MarkNotificationRead(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Result<void>> call(String id) => _repository.markRead(id);
}

class MarkAllNotificationsRead implements UseCase<void, NoParams> {
  const MarkAllNotificationsRead(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.markAllRead();
}
