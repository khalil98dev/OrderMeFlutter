import 'dart:convert';

import '../../../../core/cache/hybrid_cache.dart';
import '../../../../core/network/token_refresher.dart';
import '../../../../core/network/token_store.dart';
import '../../../../core/realtime/realtime_client.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/session_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/session_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required TokenStore tokens,
    required TokenRefresher refresher,
    required HybridCache cache,
    required RealtimeClient realtime,
  }) : _remote = remote,
       _tokens = tokens,
       _refresher = refresher,
       _cache = cache,
       _realtime = realtime;

  final AuthRemoteDataSource _remote;
  final TokenStore _tokens;
  final TokenRefresher _refresher;
  final HybridCache _cache;
  final RealtimeClient _realtime;

  @override
  Stream<void> get sessionExpired => _refresher.sessionExpired;

  @override
  Future<Result<SessionUser>> signIn({required String userName, required String password}) async {
    switch (await _remote.login(userName, password)) {
      case Err(:final failure):
        return Result.err(failure);
      case Ok(value: final pair):
        await _tokens.save(pair);
    }

    final me = await _remote.me();
    if (me case Ok(:final value)) {
      await _opened(value);
    } else {
      await _tokens.clear();
    }
    return me;
  }

  @override
  Future<Result<SessionUser?>> restoreSession() async {
    if (await _tokens.readRefreshToken() == null) return const Result.ok(null);

    switch (await _refresher.refresh()) {
      case RefreshOutcome.rejected:
        await _forget();
        return const Result.ok(null);
      case RefreshOutcome.unreachable:
        // Offline: open with the last known user and cached data; requests refresh when back online.
        final stored = await _storedUser();
        if (stored != null) {
          _cache.useScope(stored.id);
          await _realtime.connect(); // keeps retrying until the server is back
        }
        return Result.ok(stored);
      case RefreshOutcome.refreshed:
        final me = await _remote.me();
        if (me case Ok(:final value)) await _opened(value);
        return me;
    }
  }

  @override
  Future<Result<void>> signOut() async {
    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken != null) await _remote.logout(refreshToken); // best effort: offline still signs out here
    await _forget();
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> changePassword({required String currentPassword, required String newPassword}) async {
    final userName = (await _storedUser())?.userName;
    final changed = await _remote.changePassword(currentPassword, newPassword);
    if (changed case Err(:final failure)) return Result.err(failure);
    if (userName == null) return const Result.ok(null);

    // Every refresh token died with the old password: take a new pair now, before the access token expires.
    return switch (await _remote.login(userName, newPassword)) {
      Ok(value: final pair) => await _tokens.save(pair).then((_) => const Result<void>.ok(null)),
      Err(:final failure) => Result.err(failure),
    };
  }

  Future<void> _opened(SessionUser user) async {
    _cache.useScope(user.id);
    await _tokens.saveSessionUser(jsonEncode(SessionUserModel.toStoredJson(user)));
    await _realtime.connect();
  }

  Future<void> _forget() async {
    await _realtime.disconnect();
    await _tokens.clear();
    await _cache.clear();
  }

  Future<SessionUser?> _storedUser() async {
    final json = await _tokens.readSessionUser();
    if (json == null) return null;
    try {
      return SessionUserModel.fromMeJson(jsonDecode(json));
    } on Object {
      return null;
    }
  }
}
