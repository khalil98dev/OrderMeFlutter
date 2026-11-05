import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  const params = SignInParams(userName: 'teacher1', password: 'secret');
  const teacher = SessionUser(id: '1', userName: 'teacher1', role: UserRole.client);

  setUp(() {
    repository = _MockAuthRepository();
    when(() => repository.signOut()).thenAnswer((_) async => const Result.ok(null));
  });

  test('returns the user when the role matches the app', () async {
    when(
      () => repository.signIn(userName: 'teacher1', password: 'secret'),
    ).thenAnswer((_) async => const Result.ok(teacher));

    final result = await SignIn(repository, allowedRole: UserRole.client)(params);

    expect(result.fold((_) => null, (u) => u), teacher);
    verifyNever(() => repository.signOut());
  });

  test('refuses and signs out an account from the other app', () async {
    when(
      () => repository.signIn(userName: 'teacher1', password: 'secret'),
    ).thenAnswer((_) async => const Result.ok(teacher));

    final result = await SignIn(repository, allowedRole: UserRole.admin)(params);

    expect(result.fold((f) => f, (_) => null), isA<WrongAppFailure>());
    verify(() => repository.signOut()).called(1);
  });

  test('passes repository failures through', () async {
    when(
      () => repository.signIn(userName: 'teacher1', password: 'secret'),
    ).thenAnswer((_) async => const Result.err(UnauthorizedFailure()));

    final result = await SignIn(repository, allowedRole: UserRole.client)(params);

    expect(result.fold((f) => f, (_) => null), const UnauthorizedFailure());
  });
}
