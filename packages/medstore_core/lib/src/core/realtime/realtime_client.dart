import 'dart:async';
import 'dart:developer' as developer;

import 'package:signalr_netcore/signalr_client.dart';

import '../config/app_config.dart';
import '../network/token_refresher.dart';
import '../network/token_store.dart';

enum RealtimeStatus { disconnected, connecting, connected, reconnecting }

/// The app's SignalR connection to the notifications hub.
///
/// - Signs in with the same access token as HTTP, refreshed first when it is about to expire.
/// - Reconnects by itself after a drop (0, 2, 5, 10, 30 s), and retries the first connection too.
/// - Screens subscribe with [on]; handlers survive reconnects because they are registered on the hub
///   once and fanned out through broadcast streams.
///
/// The hub itself (`/hubs/notifications`) is not on the API yet; [connect] keeps retrying quietly
/// until it is.
class RealtimeClient {
  RealtimeClient({required AppConfig config, required TokenStore tokens, required TokenRefresher refresher})
    : _config = config,
      _tokens = tokens,
      _refresher = refresher;

  static const _retryDelays = [0, 2000, 5000, 10000, 30000];

  final AppConfig _config;
  final TokenStore _tokens;
  final TokenRefresher _refresher;

  final _status = StreamController<RealtimeStatus>.broadcast();
  final _channels = <String, StreamController<List<Object?>>>{};
  HubConnection? _hub;
  Timer? _retryTimer;
  var _attempt = 0;
  var _wanted = false;

  Stream<RealtimeStatus> get status => _status.stream;

  /// Messages the server sends with [method] (for example `"NotificationCreated"`).
  Stream<List<Object?>> on(String method) {
    // Closed in dispose(), which the lint cannot see through the map.
    // ignore: close_sinks
    final channel = _channels.putIfAbsent(method, () {
      _hub?.on(method, (args) => _channels[method]?.add(args ?? const []));
      return StreamController<List<Object?>>.broadcast();
    });
    return channel.stream;
  }

  Future<void> connect() async {
    _wanted = true;
    if (_hub != null) return;

    final hub = HubConnectionBuilder()
        .withUrl(_config.hubUrl, options: HttpConnectionOptions(accessTokenFactory: _accessToken))
        .withAutomaticReconnect(retryDelays: _retryDelays)
        .build();
    for (final method in _channels.keys) {
      hub.on(method, (args) => _channels[method]?.add(args ?? const []));
    }
    hub
      ..onreconnecting(({error}) => _status.add(RealtimeStatus.reconnecting))
      ..onreconnected(({connectionId}) => _status.add(RealtimeStatus.connected))
      ..onclose(({error}) {
        _status.add(RealtimeStatus.disconnected);
        if (_wanted) _scheduleRetry();
      });
    _hub = hub;
    await _start();
  }

  Future<void> disconnect() async {
    _wanted = false;
    _retryTimer?.cancel();
    final hub = _hub;
    _hub = null;
    await hub?.stop();
    _status.add(RealtimeStatus.disconnected);
  }

  Future<void> _start() async {
    final hub = _hub;
    if (hub == null || !_wanted) return;
    _status.add(RealtimeStatus.connecting);
    try {
      await hub.start();
      _attempt = 0;
      _status.add(RealtimeStatus.connected);
    } on Object catch (e) {
      developer.log('SignalR connect failed', name: 'realtime', error: e);
      _status.add(RealtimeStatus.disconnected);
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    final delay = _retryDelays[_attempt.clamp(0, _retryDelays.length - 1)];
    _attempt++;
    _retryTimer = Timer(Duration(milliseconds: delay == 0 ? 1000 : delay), _start);
  }

  Future<String> _accessToken() async {
    if (_tokens.accessTokenExpiringSoon) await _refresher.refresh();
    return _tokens.accessToken ?? '';
  }

  Future<void> dispose() async {
    await disconnect();
    await _status.close();
    for (final channel in _channels.values) {
      await channel.close();
    }
  }
}
