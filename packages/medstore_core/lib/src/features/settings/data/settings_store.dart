import 'package:hive_ce/hive_ce.dart';

/// Small device preferences (language, sidebar state). Not tied to a user, kept on sign-out.
class SettingsStore {
  SettingsStore({this.boxName = 'medstore_settings'});

  final String boxName;
  Future<Box<String>>? _box;

  Future<Box<String>> get _opened => _box ??= Hive.openBox<String>(boxName);

  Future<String?> read(String key) async => (await _opened).get(key);

  Future<void> write(String key, String? value) async {
    final box = await _opened;
    value == null ? await box.delete(key) : await box.put(key, value);
  }
}
