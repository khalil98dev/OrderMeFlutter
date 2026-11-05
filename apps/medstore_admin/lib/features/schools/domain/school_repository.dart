import 'package:medstore_core/medstore_core.dart';

import 'school.dart';

/// `/api/admin/schools`: a plain list (no paging), small enough to keep in the cache.
abstract interface class SchoolRepository {
  Future<Result<List<School>>> list(SchoolFilter filter);

  Future<Result<School>> create(SchoolDraft draft);

  Future<Result<void>> update(String id, SchoolDraft draft);
}

class ListSchools implements UseCase<List<School>, SchoolFilter> {
  const ListSchools(this._repository);

  final SchoolRepository _repository;

  @override
  Future<Result<List<School>>> call(SchoolFilter filter) => _repository.list(filter);
}

final class SaveSchoolParams {
  const SaveSchoolParams(this.draft, {this.schoolId});

  final SchoolDraft draft;

  /// Null creates a new school.
  final String? schoolId;
}

/// Creates or updates a school.
class SaveSchool implements UseCase<void, SaveSchoolParams> {
  const SaveSchool(this._repository);

  final SchoolRepository _repository;

  @override
  Future<Result<void>> call(SaveSchoolParams params) async => switch (params.schoolId) {
    null => (await _repository.create(params.draft)).map((_) {}),
    final id => await _repository.update(id, params.draft),
  };
}
