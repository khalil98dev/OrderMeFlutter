import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../core/result/result.dart';
import '../domain/entities/session_user.dart';
import '../domain/usecases/sign_in.dart';

enum LoginStatus { editing, submitting, failed, succeeded }

final class LoginState extends Equatable {
  const LoginState({this.status = LoginStatus.editing, this.failure, this.user});

  final LoginStatus status;
  final Failure? failure;
  final SessionUser? user;

  bool get isSubmitting => status == LoginStatus.submitting;

  @override
  List<Object?> get props => [status, failure, user];
}

/// The login form. One per login screen (registered as a factory).
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._signIn) : super(const LoginState());

  final SignIn _signIn;

  Future<void> submit({required String userName, required String password}) async {
    if (state.isSubmitting) return; // a double tap must not sign in twice
    emit(const LoginState(status: LoginStatus.submitting));

    final result = await _signIn(SignInParams(userName: userName.trim(), password: password));
    emit(switch (result) {
      Ok(:final value) => LoginState(status: LoginStatus.succeeded, user: value),
      Err(:final failure) => LoginState(status: LoginStatus.failed, failure: failure),
    });
  }

  /// Hides the error once the user edits a field again.
  void edited() {
    if (state.status == LoginStatus.failed) emit(const LoginState());
  }
}
