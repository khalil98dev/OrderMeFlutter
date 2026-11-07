import 'dart:typed_data';

import 'package:medstore_core/medstore_core.dart';

import 'statement.dart';
import 'teacher.dart';

/// `/api/admin/clients`: teachers, their sign-in accounts and their statements.
abstract interface class TeacherRepository {
  Future<Result<PagedList<Teacher>>> list(TeacherFilter filter, {int page = 1});

  Future<Result<Teacher>> get(String id);

  /// Creates the teacher and their sign-in account together.
  Future<Result<Teacher>> create(TeacherDraft draft);

  Future<Result<void>> update(String id, TeacherDraft draft);

  /// Closes the account and ends its sessions. Orders and invoices stay.
  Future<Result<void>> deactivate(String id);

  /// Gives the teacher a new password without the current one (they forgot it), and ends their
  /// sessions. `POST /api/admin/clients/{id}/password`.
  Future<Result<void>> setPassword(String id, String newPassword);

  /// The account for a period (local days, both included, at most 366 days).
  Future<Result<Statement>> statement(String id, {DateTime? from, DateTime? to});

  /// The same statement as a PDF ("Relevé de compte").
  Future<Result<Uint8List>> statementPdf(String id, {DateTime? from, DateTime? to});
}

final class StatementParams {
  const StatementParams(this.clientId, {this.from, this.to});

  final String clientId;
  final DateTime? from;
  final DateTime? to;
}

class ListTeachers {
  const ListTeachers(this._repository);

  final TeacherRepository _repository;

  Future<Result<PagedList<Teacher>>> call(TeacherFilter filter, {int page = 1}) =>
      _repository.list(filter, page: page);
}

class GetTeacher implements UseCase<Teacher, String> {
  const GetTeacher(this._repository);

  final TeacherRepository _repository;

  @override
  Future<Result<Teacher>> call(String id) => _repository.get(id);
}

final class SaveTeacherParams {
  const SaveTeacherParams(this.draft, {this.teacherId});

  final TeacherDraft draft;

  /// Null creates a new teacher with a sign-in account.
  final String? teacherId;
}

/// Creates or updates a teacher.
class SaveTeacher implements UseCase<void, SaveTeacherParams> {
  const SaveTeacher(this._repository);

  final TeacherRepository _repository;

  @override
  Future<Result<void>> call(SaveTeacherParams params) async => switch (params.teacherId) {
    null => (await _repository.create(params.draft)).map((_) {}),
    final id => await _repository.update(id, params.draft),
  };
}

class DeactivateTeacher implements UseCase<void, String> {
  const DeactivateTeacher(this._repository);

  final TeacherRepository _repository;

  @override
  Future<Result<void>> call(String id) => _repository.deactivate(id);
}

final class SetTeacherPasswordParams {
  const SetTeacherPasswordParams(this.teacherId, this.newPassword);

  final String teacherId;
  final String newPassword;
}

class SetTeacherPassword implements UseCase<void, SetTeacherPasswordParams> {
  const SetTeacherPassword(this._repository);

  final TeacherRepository _repository;

  @override
  Future<Result<void>> call(SetTeacherPasswordParams params) =>
      _repository.setPassword(params.teacherId, params.newPassword);
}

class GetStatement implements UseCase<Statement, StatementParams> {
  const GetStatement(this._repository);

  final TeacherRepository _repository;

  @override
  Future<Result<Statement>> call(StatementParams params) =>
      _repository.statement(params.clientId, from: params.from, to: params.to);
}

class DownloadStatementPdf implements UseCase<Uint8List, StatementParams> {
  const DownloadStatementPdf(this._repository);

  final TeacherRepository _repository;

  @override
  Future<Result<Uint8List>> call(StatementParams params) =>
      _repository.statementPdf(params.clientId, from: params.from, to: params.to);
}
