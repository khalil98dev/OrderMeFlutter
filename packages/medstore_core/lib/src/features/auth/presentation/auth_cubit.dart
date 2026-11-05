import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../core/usecase/use_case.dart';
import '../domain/entities/session_user.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/restore_session.dart';
import '../domain/usecases/sign_out.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Start-up: the stored session is being checked. The router shows the splash screen.
final class AuthUnknown extends AuthState {
  const AuthUnknown();
}

final class Authenticated extends AuthState {
  const Authenticated(this.user);

  final SessionUser user;

  @override
  List<Object?> get props => [user];
}

final class Unauthenticated extends AuthState {
  const Unauthenticated([this.reason]);

  /// Why the session ended, when it was not the user's choice (expired elsewhere).
  final Failure? reason;

  @override
  List<Object?> get props => [reason];
}

/// The app-wide session. Lives for the whole app; the router listens to it.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required RestoreSession restoreSession,
    required SignOut signOut,
    required AuthRepository repository,
  }) : _restoreSession = restoreSession,
       _signOut = signOut,
       super(const AuthUnknown()) {
    _expired = repository.sessionExpired.listen(
      (_) => emit(const Unauthenticated(UnauthorizedFailure('Session expired'))),
    );
  }

  final RestoreSession _restoreSession;
  final SignOut _signOut;
  late final StreamSubscription<void> _expired;

  Future<void> restore() async {
    final result = await _restoreSession(const NoParams());
    emit(
      result.fold(
        (_) => const Unauthenticated(),
        (user) => user == null ? const Unauthenticated() : Authenticated(user),
      ),
    );
  }

  /// Called by the login screen once `SignIn` succeeded.
  void signedIn(SessionUser user) => emit(Authenticated(user));

  Future<void> signOut() async {
    await _signOut(const NoParams());
    emit(const Unauthenticated());
  }

  @override
  Future<void> close() async {
    await _expired.cancel();
    return super.close();
  }
}
