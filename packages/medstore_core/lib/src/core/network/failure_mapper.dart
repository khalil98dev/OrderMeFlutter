import 'package:dio/dio.dart';

import '../error/failure.dart';

/// Turns a [DioException] into a [Failure], reading the API's ProblemDetails body when there is one.
abstract final class FailureMapper {
  static Failure fromDio(DioException e) => switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout ||
    DioExceptionType.connectionError ||
    DioExceptionType.badCertificate ||
    DioExceptionType.unknown => NetworkFailure(e.message),
    DioExceptionType.cancel => const CancelledFailure(),
    DioExceptionType.badResponse => fromResponse(e.response),
  };

  static Failure fromResponse(Response<Object?>? response) {
    final body = response?.data;
    final problem = body is Map<String, Object?> ? body : const <String, Object?>{};
    final detail = (problem['detail'] ?? problem['title']) as String?;

    return switch (response?.statusCode ?? 0) {
      400 || 422 => ValidationFailure(_errors(problem['errors']), detail),
      401 => UnauthorizedFailure(detail),
      403 => ForbiddenFailure(detail, _strings(problem['deniedFields'])),
      404 => NotFoundFailure(detail),
      409 => ConflictFailure(detail),
      _ => ServerFailure(detail),
    };
  }

  static Map<String, List<String>> _errors(Object? value) {
    if (value is! Map<String, Object?>) return const {};
    return {for (final MapEntry(:key, :value) in value.entries) key: _strings(value)};
  }

  static List<String> _strings(Object? value) =>
      value is List<Object?> ? [for (final item in value) '$item'] : const [];
}
