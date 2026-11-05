/// Values that differ per environment, read at compile time.
///
/// Run with `--dart-define-from-file=env/dev.json` (each app has an `env/` folder).
/// Nothing secret belongs here: everything in a Flutter build can be read from the binary.
final class AppConfig {
  const AppConfig({required this.apiBaseUrl, this.hubPath = '/hubs/notifications'});

  factory AppConfig.fromEnvironment() => const AppConfig(
    apiBaseUrl: String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:60613'),
  );

  /// Scheme, host and port of the API, without a trailing slash (`https://api.medstore.dz`).
  final String apiBaseUrl;

  /// Path of the SignalR notifications hub on the API.
  final String hubPath;

  String get hubUrl => '$apiBaseUrl$hubPath';
}
