import 'package:equatable/equatable.dart';
import 'package:medstore_core/medstore_core.dart';

// The little the product form needs to know about teachers. The full Teachers feature (create, edit,
// deactivate) will grow from here.

/// A teacher, as shown in pickers and lists.
final class TeacherSummary extends Equatable {
  const TeacherSummary({required this.id, required this.fullName, this.schoolName, this.subject});

  final String id;
  final String fullName;
  final String? schoolName;
  final String? subject;

  @override
  List<Object?> get props => [id, fullName, schoolName, subject];
}

abstract interface class TeacherDirectory {
  /// Active teachers whose name matches [search] (all of them when empty), first page only.
  Future<Result<List<TeacherSummary>>> search(String search);
}

class SearchTeachers implements UseCase<List<TeacherSummary>, String> {
  const SearchTeachers(this._directory);

  final TeacherDirectory _directory;

  @override
  Future<Result<List<TeacherSummary>>> call(String search) => _directory.search(search);
}
