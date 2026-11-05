import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_core/src/core/network/failure_mapper.dart';

DioException _bad(int status, [Object? body]) {
  final options = RequestOptions(path: '/x');
  return DioException.badResponse(
    statusCode: status,
    requestOptions: options,
    response: Response<Object?>(requestOptions: options, statusCode: status, data: body),
  );
}

void main() {
  test('validation problem keeps per-field errors and the detail', () {
    final failure = FailureMapper.fromDio(
      _bad(400, {
        'title': 'One or more validation errors occurred.',
        'errors': {
          'Name': ['Required'],
        },
      }),
    );
    expect(
      failure,
      const ValidationFailure({
        'Name': ['Required'],
      }, 'One or more validation errors occurred.'),
    );
  });

  test('403 keeps the denied fields', () {
    final failure = FailureMapper.fromDio(
      _bad(403, {
        'detail': 'no',
        'deniedFields': ['Price'],
      }),
    );
    expect(failure, const ForbiddenFailure('no', ['Price']));
  });

  test('status codes map to their failure types', () {
    expect(FailureMapper.fromDio(_bad(401)), isA<UnauthorizedFailure>());
    expect(FailureMapper.fromDio(_bad(404)), isA<NotFoundFailure>());
    expect(FailureMapper.fromDio(_bad(409)), isA<ConflictFailure>());
    expect(FailureMapper.fromDio(_bad(500)), isA<ServerFailure>());
  });

  test('no connection is a NetworkFailure, a cancel is a CancelledFailure', () {
    final options = RequestOptions(path: '/x');
    expect(
      FailureMapper.fromDio(DioException.connectionError(requestOptions: options, reason: 'x')),
      isA<NetworkFailure>(),
    );
    expect(
      FailureMapper.fromDio(DioException.requestCancelled(requestOptions: options, reason: null)),
      isA<CancelledFailure>(),
    );
  });
}
