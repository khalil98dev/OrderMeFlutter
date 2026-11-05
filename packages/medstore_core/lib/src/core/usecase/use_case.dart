import '../result/result.dart';

/// One application action. Presentation (Blocs/Cubits) calls use cases, never repositories.
abstract interface class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// For use cases that take no input.
final class NoParams {
  const NoParams();
}
