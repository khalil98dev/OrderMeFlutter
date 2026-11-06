import 'package:medstore_core/medstore_core.dart';

import '../domain/notification.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl({required ApiClient api, required RealtimeClient realtime})
    : _api = api,
      _realtime = realtime;

  static const _path = '/api/notifications';

  final ApiClient _api;
  final RealtimeClient _realtime;

  @override
  Future<Result<PagedList<AppNotification>>> list(NotificationFilter filter, {int page = 1}) => _api.get(
    _path,
    query: {if (filter.unreadOnly) 'unreadOnly': true, 'page': page, 'pageSize': 30},
    decode: (json) => PagedList.fromJson(json, fromJson),
  );

  @override
  Future<Result<void>> markRead(String id) => _api.post('$_path/$id/read', decode: ApiClient.ignoreBody);

  @override
  Future<Result<void>> markAllRead() => _api.post('$_path/read-all', decode: ApiClient.ignoreBody);

  @override
  Stream<void> get created => _realtime.on('NotificationCreated');

  static AppNotification fromJson(Object? raw) {
    final json = JsonMap.of(raw);
    return AppNotification(
      id: json.string('id'),
      title: json.string('title'),
      message: json.stringOrNull('message'),
      type: json.stringOrNull('type'),
      isRead: json.booleanOrNull('isRead') ?? false,
      createdAt: json.instant('createdAt'),
    );
  }
}
