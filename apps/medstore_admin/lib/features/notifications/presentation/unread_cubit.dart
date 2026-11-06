import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';

import '../domain/notification.dart';

/// How many notifications the team member has not read: the sidebar's badge. One for the app.
///
/// A notification pushed live adds one at once; [refresh] asks the server for the true count (at
/// sign-in, after reading).
class UnreadCubit extends Cubit<int> {
  UnreadCubit(this._repository) : super(0) {
    _live = _repository.arrivals.listen((_) {
      if (_active) emit(state + 1);
    });
  }

  final NotificationRepository _repository;
  late final StreamSubscription<AppNotification> _live;
  var _active = false;

  Future<void> start() {
    _active = true;
    return refresh();
  }

  Future<void> refresh() async {
    if (!_active) return;
    final result = await _repository.unreadCount();
    if (isClosed || !_active) return;
    if (result case Ok(:final value)) emit(value);
  }

  /// One was read on this device.
  void read() {
    if (state > 0) emit(state - 1);
  }

  void allRead() => emit(0);

  /// Signed out.
  void stop() {
    _active = false;
    emit(0);
  }

  @override
  Future<void> close() async {
    await _live.cancel();
    return super.close();
  }
}
