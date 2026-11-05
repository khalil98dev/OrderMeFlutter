import 'package:equatable/equatable.dart';
import 'package:medstore_core/medstore_core.dart';

/// A teacher ("client" on the API) with their sign-in account.
final class Teacher extends Equatable {
  const Teacher({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.isActive,
    required this.createdAt,
    this.userName,
    this.phone,
    this.subject,
    this.schoolId,
    this.schoolName,
    this.paymentTerms,
  });

  final String id;
  final String userId;
  final String? userName;
  final String fullName;
  final String? phone;
  final String? subject;
  final String? schoolId;
  final String? schoolName;

  /// Null when this user may not read it (a secured field).
  final PaymentTerms? paymentTerms;
  final bool isActive;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    fullName,
    phone,
    subject,
    schoolId,
    schoolName,
    paymentTerms,
    isActive,
    createdAt,
  ];
}

/// What the teachers list shows.
final class TeacherFilter extends Equatable {
  const TeacherFilter({this.search = '', this.schoolId, this.isActive = true});

  final String search;
  final String? schoolId;

  /// Null: active and deactivated.
  final bool? isActive;

  TeacherFilter copyWith({String? search, String? Function()? schoolId, bool? Function()? isActive}) =>
      TeacherFilter(
        search: search ?? this.search,
        schoolId: schoolId == null ? this.schoolId : schoolId(),
        isActive: isActive == null ? this.isActive : isActive(),
      );

  @override
  List<Object?> get props => [search, schoolId, isActive];
}

enum TeacherField { userName, password, fullName }

/// The teacher form. A new teacher also gets a sign-in account ([userName], [password], [email]).
final class TeacherDraft extends Equatable {
  const TeacherDraft({
    required this.fullName,
    this.userName = '',
    this.password = '',
    this.email = '',
    this.phone = '',
    this.subject = '',
    this.schoolId,
    this.paymentTerms,
  });

  factory TeacherDraft.of(Teacher teacher) => TeacherDraft(
    fullName: teacher.fullName,
    phone: teacher.phone ?? '',
    subject: teacher.subject ?? '',
    schoolId: teacher.schoolId,
    paymentTerms: teacher.paymentTerms,
  );

  final String fullName;
  final String userName;
  final String password;
  final String email;
  final String phone;
  final String subject;
  final String? schoolId;

  /// Null on a new teacher: the billing settings' default.
  final PaymentTerms? paymentTerms;

  Set<TeacherField> validate({required bool isNew}) => {
    if (fullName.trim().isEmpty) TeacherField.fullName,
    if (isNew && userName.trim().isEmpty) TeacherField.userName,
    if (isNew && password.length < ChangePassword.minLength) TeacherField.password,
  };

  @override
  List<Object?> get props => [fullName, userName, password, email, phone, subject, schoolId, paymentTerms];
}
