/// Centralizes all backend connection and game timing config.
/// Change only this file when switching from local to production.
class AppConfig {
  // ---------------------------------------------------------------
  // Server URL
  // ---------------------------------------------------------------
  // Android emulator  → http://10.0.2.2:3000
  // iOS simulator     → http://localhost:3000
  // Physical device   → http://<your-PC-IP>:3000
  // Web / Desktop     → http://localhost:3000
  static const String serverUrl = 'http://10.0.2.2:3000';

  // ---------------------------------------------------------------
  // Game timing (must match backend's roundDurationMs / 1000 = 12)
  // ---------------------------------------------------------------

  /// Seconds spent flashing numbers (first portion of the round).
  static const int flashDurationSec = 10;

  /// Seconds given to type the answer (remaining portion).
  static const int answerDurationSec = 5;

  static const int roundDurationSec = 15;
}
