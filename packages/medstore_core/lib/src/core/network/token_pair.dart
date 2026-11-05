/// What `POST /api/auth/login` and `/refresh` return (SecurityBuilder's `TokenPair`).
final class TokenPair {
  const TokenPair({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
  });

  factory TokenPair.fromJson(Map<String, Object?> json) => TokenPair(
    accessToken: json['accessToken']! as String,
    accessTokenExpiresAt: DateTime.parse(json['accessTokenExpiresAt']! as String),
    refreshToken: json['refreshToken']! as String,
    refreshTokenExpiresAt: DateTime.parse(json['refreshTokenExpiresAt']! as String),
  );

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
}
