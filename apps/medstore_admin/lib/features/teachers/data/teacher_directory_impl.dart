import 'package:medstore_core/medstore_core.dart';

import '../domain/teacher_directory.dart';

/// `GET /api/admin/clients` (teachers are "clients" on the API).
class TeacherDirectoryImpl implements TeacherDirectory {
  const TeacherDirectoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<Result<List<TeacherSummary>>> search(String search) => _api.get(
    '/api/admin/clients',
    query: {if (search.isNotEmpty) 'search': search, 'isActive': true, 'pageSize': 50},
    decode: (json) => PagedList.fromJson(json, _teacherFromJson).items,
  );

  static TeacherSummary _teacherFromJson(Object? json) {
    final map = json! as Map<String, Object?>;
    return TeacherSummary(
      id: map['id']! as String,
      fullName: map['fullName']! as String,
      schoolName: map['schoolName'] as String?,
      subject: map['subject'] as String?,
    );
  }
}
