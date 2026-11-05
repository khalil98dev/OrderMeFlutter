/// Reads one JSON object from the API with its conventions (docs/api/README.md §3):
/// a missing key is null, instants are ISO 8601 with an offset, days are "yyyy-MM-dd", money is a number.
///
/// ```dart
/// final json = JsonMap.of(raw);
/// Invoice(id: json.string('id'), dueDate: json.day('dueDate'), amountDue: json.moneyOrNull('amountDue'));
/// ```
///
/// A required key that is missing throws, which `ApiClient` reports as "could not read the answer":
/// the API and the app disagree on a shape, and that must not pass silently.
extension type const JsonMap(Map<String, Object?> _map) {
  factory JsonMap.of(Object? json) => JsonMap(json! as Map<String, Object?>);

  Object? operator [](String key) => _map[key];

  String string(String key) => _map[key]! as String;
  String? stringOrNull(String key) => _map[key] as String?;

  int integer(String key) => (_map[key]! as num).toInt();
  int? integerOrNull(String key) => (_map[key] as num?)?.toInt();

  num money(String key) => _map[key]! as num;
  num? moneyOrNull(String key) => _map[key] as num?;

  bool boolean(String key) => _map[key]! as bool;
  bool? booleanOrNull(String key) => _map[key] as bool?;

  /// An instant ("2026-11-04T20:34:56.35+00:00"), in UTC.
  DateTime instant(String key) => DateTime.parse(string(key)).toUtc();
  DateTime? instantOrNull(String key) => switch (stringOrNull(key)) {
    final value? => DateTime.parse(value).toUtc(),
    null => null,
  };

  /// A day without time ("2026-11-30"), at local midnight.
  DateTime day(String key) => parseApiDay(string(key));
  DateTime? dayOrNull(String key) => switch (stringOrNull(key)) {
    final value? => parseApiDay(value),
    null => null,
  };

  JsonMap object(String key) => JsonMap.of(_map[key]);

  List<T> list<T>(String key, T Function(Object? json) item) => [
    for (final element in (_map[key] as List<Object?>? ?? const [])) item(element),
  ];

  /// An object of string values (`fields: {"Price": "Read"}`); empty when missing.
  Map<String, String> stringMap(String key) => {
    for (final MapEntry(:key, :value) in (_map[key] as Map<String, Object?>? ?? const {}).entries)
      key: value! as String,
  };
}

/// "2026-11-30" → that day at local midnight.
DateTime parseApiDay(String value) {
  final date = DateTime.parse(value);
  return DateTime(date.year, date.month, date.day);
}

/// A day as the API's query strings and bodies expect it: "2026-11-30".
String apiDay(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
