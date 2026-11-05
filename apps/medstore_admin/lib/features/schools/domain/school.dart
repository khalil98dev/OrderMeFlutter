import 'package:equatable/equatable.dart';

enum SchoolLevel {
  primary('Primary'),
  middle('Middle'),
  secondary('Secondary'),
  university('University'),
  other('Other');

  const SchoolLevel(this.apiName);

  final String apiName;

  static SchoolLevel fromApi(String? value) =>
      values.firstWhere((level) => level.apiName == value, orElse: () => other);
}

enum SchoolType {
  public('Public'),
  private('Private');

  const SchoolType(this.apiName);

  final String apiName;

  static SchoolType fromApi(String? value) =>
      values.firstWhere((type) => type.apiName == value, orElse: () => public);
}

/// A school where teachers work. Used to group teachers and sales (reports by school and wilaya).
final class School extends Equatable {
  const School({
    required this.id,
    required this.name,
    required this.wilayaCode,
    required this.level,
    required this.type,
    this.city,
  });

  final String id;
  final String name;

  /// The official wilaya number (16 = Alger, 31 = Oran…).
  final int wilayaCode;
  final String? city;
  final SchoolLevel level;
  final SchoolType type;

  @override
  List<Object?> get props => [id, name, wilayaCode, city, level, type];
}

/// What the schools list shows.
final class SchoolFilter extends Equatable {
  const SchoolFilter({this.search = '', this.wilayaCode});

  final String search;
  final int? wilayaCode;

  @override
  List<Object?> get props => [search, wilayaCode];
}

enum SchoolField { name, wilaya }

/// The school form, with the server's rules.
final class SchoolDraft extends Equatable {
  const SchoolDraft({
    required this.name,
    required this.wilayaText,
    this.city = '',
    this.level = SchoolLevel.secondary,
    this.type = SchoolType.public,
  });

  factory SchoolDraft.of(School school) => SchoolDraft(
    name: school.name,
    wilayaText: '${school.wilayaCode}',
    city: school.city ?? '',
    level: school.level,
    type: school.type,
  );

  /// Algeria has 58 wilayas.
  static const maxWilaya = 58;

  final String name;
  final String wilayaText;
  final String city;
  final SchoolLevel level;
  final SchoolType type;

  int? get wilayaCode => int.tryParse(wilayaText.trim());

  Set<SchoolField> validate() => {
    if (name.trim().isEmpty) SchoolField.name,
    if (wilayaCode == null || wilayaCode! < 1 || wilayaCode! > maxWilaya) SchoolField.wilaya,
  };

  @override
  List<Object?> get props => [name, wilayaText, city, level, type];
}
