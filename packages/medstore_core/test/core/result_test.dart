import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_core/medstore_core.dart';

void main() {
  test('map transforms a success', () {
    const Result<int> result = Result.ok(2);
    expect(result.map((v) => v * 10).fold((_) => -1, (v) => v), 20);
  });

  test('map passes a failure through', () {
    const Result<int> result = Result.err(NotFoundFailure());
    final mapped = result.map((v) => v * 10);
    expect(mapped.fold((f) => f, (_) => null), const NotFoundFailure());
  });
}
