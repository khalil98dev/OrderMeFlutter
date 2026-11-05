import 'package:medstore_core/medstore_core.dart';

import 'l10n/app_strings.dart';

/// The sentence to show for a [Failure], in the user's language.
String failureText(AppStrings strings, Failure failure) => switch (failure) {
  NetworkFailure() => strings.failureNetwork,
  UnauthorizedFailure() => strings.failureUnauthorized,
  ForbiddenFailure() => strings.failureForbidden,
  NotFoundFailure() => strings.failureNotFound,
  ConflictFailure() => strings.failureConflict,
  ValidationFailure() => strings.failureValidation,
  WrongAppFailure() => strings.failureWrongApp,
  ServerFailure() => strings.failureServer,
  CancelledFailure() || UnexpectedFailure() => strings.failureUnexpected,
};
