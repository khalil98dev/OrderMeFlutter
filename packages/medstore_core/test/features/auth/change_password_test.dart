import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_core/src/core/network/token_pair.dart';
import 'package:medstore_core/src/core/network/token_refresher.dart';
import 'package:medstore_core/src/core/network/token_store.dart';
import 'package:medstore_core/src/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:medstore_core/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements AuthRemoteDataSource {}

class _MockTokens extends Mock implements TokenStore {}

class _MockRefresher extends Mock implements TokenRefresher {}

class _MockCache extends Mock implements HybridCache {}

class _MockRealtime extends Mock implements RealtimeClient {}

final _pair = TokenPair(
  accessToken: 'a2',
  accessTokenExpiresAt: DateTime.utc(2026, 11, 5, 10),
  refreshToken: 'r2',
  refreshTokenExpiresAt: DateTime.utc(2026, 11, 19),
);

void main() {
  late _MockRemote remote;
  late _MockTokens tokens;
  late AuthRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(_pair));

  setUp(() {
    remote = _MockRemote();
    tokens = _MockTokens();
    repository = AuthRepositoryImpl(
      remote: remote,
      tokens: tokens,
      refresher: _MockRefresher(),
      cache: _MockCache(),
      realtime: _MockRealtime(),
    );
    when(
      () => tokens.readSessionUser(),
    ).thenAnswer((_) async => '{"userId":"1","userName":"admin","roles":["Admin"]}');
    when(() => tokens.save(any())).thenAnswer((_) async {});
  });

  test('after the change, signs in again with the new password: every old session ended', () async {
    when(
      () => remote.changePassword('old-secret', 'new-secret'),
    ).thenAnswer((_) async => const Result.ok(null));
    when(() => remote.login('admin', 'new-secret')).thenAnswer((_) async => Result.ok(_pair));

    final result = await ChangePassword(repository)(
      const ChangePasswordParams(currentPassword: 'old-secret', newPassword: 'new-secret'),
    );

    expect(result.isOk, isTrue);
    verify(() => tokens.save(_pair)).called(1);
  });

  test('a wrong current password is reported and nothing else happens', () async {
    when(() => remote.changePassword(any(), any())).thenAnswer(
      (_) async => const Result.err(
        ValidationFailure({
          'Password.Mismatch': ['wrong'],
        }),
      ),
    );

    final result = await repository.changePassword(currentPassword: 'bad', newPassword: 'new-secret');

    expect(result.fold((failure) => failure, (_) => null), isA<ValidationFailure>());
    verifyNever(() => remote.login(any(), any()));
  });
}
