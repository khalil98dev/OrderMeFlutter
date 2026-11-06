import 'package:equatable/equatable.dart';
import 'package:medstore_core/medstore_core.dart';

/// An in-app notification for the signed-in team member.
///
/// ASSUMED API (the backend has no notifications endpoint yet), adjust here when it lands:
/// `GET /api/notifications?page&pageSize&unreadOnly`, `POST /api/notifications/{id}/read`,
/// `POST /api/notifications/read-all`, and the SignalR event `NotificationCreated`.
final class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.createdAt,
    this.message,
    this.type,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String? message;

  /// Free text from the server (`OrderPlaced`, `InvoiceOverdue`…), used only to pick an icon.
  final String? type;
  final bool isRead;
  final DateTime createdAt;

  AppNotification asRead() =>
      AppNotification(id: id, title: title, message: message, type: type, createdAt: createdAt, isRead: true);

  @override
  List<Object?> get props => [id, title, message, type, isRead, createdAt];
}

final class NotificationFilter extends Equatable {
  const NotificationFilter({this.unreadOnly = false});

  final bool unreadOnly;

  @override
  List<Object?> get props => [unreadOnly];
}

abstract interface class NotificationRepository {
  Future<Result<PagedList<AppNotification>>> list(NotificationFilter filter, {int page = 1});

  Future<Result<void>> markRead(String id);

  Future<Result<void>> markAllRead();

  /// Fires when the server pushes a new notification.
  Stream<void> get created;
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
