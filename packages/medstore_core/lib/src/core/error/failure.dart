import 'package:equatable/equatable.dart';

/// Every way a use case can fail, as a value (never an exception crossing layers).
///
/// The data layer maps HTTP answers to these (`FailureMapper`). The UI turns the *type* into a
/// localized sentence (`medstore_ui`'s `failureText`); [detail] is the server's own text
/// (ProblemDetails `detail`), kept for logs and for the rare screen that shows it.
///
/// Mapping follows the backend: 401 = not signed in (refresh, then login), 403 = signed in but not allowed.
sealed class Failure extends Equatable {
  const Failure([this.detail]);

  final String? detail;

  @override
  List<Object?> get props => [detail];
}

/// No connection, timeout, DNS failure, server unreachable.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.detail]);
}

/// 401 after a refresh attempt also failed (or a wrong password at sign-in).
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.detail]);
}

/// 403: signed in, but this action is not allowed for this user.
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.detail, this.deniedFields = const []]);

  /// Fields the user may not set, when the API lists them.
  final List<String> deniedFields;

  @override
  List<Object?> get props => [detail, deniedFields];
}

/// 404.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.detail]);
}

/// 409: someone else changed the record first.
final class ConflictFailure extends Failure {
  const ConflictFailure([super.detail]);
}

/// 400 / 422. [errors] holds per-field messages from the API's validation (may be empty).
final class ValidationFailure extends Failure {
  const ValidationFailure([this.errors = const {}, super.detail]);

  final Map<String, List<String>> errors;

  @override
  List<Object?> get props => [detail, errors];
}

/// The account is valid but belongs to the other app (an admin in the teacher app, or the reverse).
final class WrongAppFailure extends Failure {
  const WrongAppFailure([super.detail]);
}

/// The request was cancelled on purpose (screen closed). Screens ignore it.
final class CancelledFailure extends Failure {
  const CancelledFailure([super.detail]);
}

/// 5xx or an answer the app could not understand.
final class ServerFailure extends Failure {
  const ServerFailure([super.detail]);
}

/// A bug on our side. Log it; show a generic message.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.detail, this.error]);

  final Object? error;
}
