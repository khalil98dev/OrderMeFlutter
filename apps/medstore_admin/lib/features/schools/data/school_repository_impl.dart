import 'package:medstore_core/medstore_core.dart';

import '../../../app/forms/form_values.dart';
import '../domain/school.dart';
import '../domain/school_repository.dart';

/// Schools change rarely and every teacher form needs them: lists are cached 10 minutes, and dropped
/// after any change.
class SchoolRepositoryImpl implements SchoolRepository {
  SchoolRepositoryImpl({required ApiClient api, required HybridCache cache}) : _api = api, _cache = cache;

  static const _path = '/api/admin/schools';
  static const _cacheKey = 'admin-schools';

  final ApiClient _api;
  final HybridCache _cache;

  @override
  Future<Result<List<School>>> list(SchoolFilter filter) {
    final query = {
      if (filter.search.isNotEmpty) 'search': filter.search,
      if (filter.wilayaCode != null) 'wilayaCode': filter.wilayaCode,
    };
    return _cache
        .fetch(
          key: '$_cacheKey?${query.entries.map((e) => '${e.key}=${e.value}').join('&')}',
          maxAge: const Duration(minutes: 10),
          fetch: () => _api.get(_path, query: query, decode: ApiClient.rawJson),
          decode: (json) => [for (final item in json! as List<Object?>) schoolFromJson(item)],
        )
        .last; // the fresh list, or the cached one when offline
  }

  @override
  Future<Result<School>> create(SchoolDraft draft) =>
      _afterChange(_api.post(_path, data: _body(draft), decode: schoolFromJson));

  @override
  Future<Result<void>> update(String id, SchoolDraft draft) =>
      _afterChange(_api.put('$_path/$id', data: _body(draft), decode: ApiClient.ignoreBody));

  static Map<String, Object?> _body(SchoolDraft draft) => {
    'name': draft.name.trim(),
    'wilayaCode': draft.wilayaCode,
    'city': optionalText(draft.city),
    'level': draft.level.apiName,
    'type': draft.type.apiName,
  };

  Future<Result<T>> _afterChange<T>(Future<Result<T>> change) async {
    final result = await change;
    if (result.isOk) await _cache.invalidate(_cacheKey);
    return result;
  }

  static School schoolFromJson(Object? raw) {
    final json = JsonMap.of(raw);
    return School(
      id: json.string('id'),
      name: json.string('name'),
      wilayaCode: json.integer('wilayaCode'),
      city: json.stringOrNull('city'),
      level: SchoolLevel.fromApi(json.stringOrNull('level')),
      type: SchoolType.fromApi(json.stringOrNull('type')),
    );
  }
}
