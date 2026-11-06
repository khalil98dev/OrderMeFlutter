import 'dart:developer' as developer;

import 'package:medstore_core/medstore_core.dart';

import '../domain/notification.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({required ApiClient api, required RealtimeClient realtime})
    : _api = api,
      _realtime = realtime;

  static const _path = '/api/notifications';

  /// The client method the hub calls (`NotificationsHub.NotificationMethod`).
  static const _hubMethod = 'notification';

  final ApiClient _api;
  final RealtimeClient _realtime;

  @override
  Future<Result<PagedList<TeacherNotification>>> list(NotificationFilter filter, {int page = 1}) => _api.get(
    _path,
    query: {if (filter.unreadOnly) 'unreadOnly': true, 'page': page, 'pageSize': 30},
    decode: (json) => PagedList.fromJson(json, fromJson),
  );

  @override
  Future<Result<int>> unreadCount() =>
      _api.get('$_path/unread-count', decode: (json) => JsonMap.of(json).integer('unread'));

  @override
  Future<Result<void>> markRead(String id) => _api.post('$_path/$id/read', decode: ApiClient.ignoreBody);

  @override
  Future<Result<void>> markAllRead() => _api.post('$_path/read-all', decode: ApiClient.ignoreBody);

  @override
  late final Stream<TeacherNotification> arrivals = _realtime.on(_hubMethod).expand((args) sync* {
    if (args.isEmpty) return;
    try {
      yield fromJson(args.first);
    } on Object catch (e) {
      // A shape this version cannot read: skip it, the list still shows it after a reload.
      developer.log('Unreadable notification', name: 'notifications', error: e);
    }
  });

  static TeacherNotification fromJson(Object? raw) {
    final json = JsonMap.of(raw);
    return TeacherNotification(
      id: json.string('id'),
      type: NotificationKind.fromApi(json.stringOrNull('type')),
      title: json.stringOrNull('title') ?? '',
      message: json.stringOrNull('message') ?? '',
      data: json.stringMap('data'),
      link: json.stringOrNull('link'),
      createdAt: json.instant('createdAt'),
      readAt: json.instantOrNull('readAt'),
    );
  }
}
