// ─────────────────────────────────────────────────────────────────────────────
//  Healio — API Configuration
//  Change BASE_URL to your server address when deploying.
//
//  Local development defaults:
//    Android emulator  → http://10.0.2.2:8000   (maps to host localhost)
//    iOS simulator     → http://localhost:8000
//    Real device       → http://<your-machine-ip>:8000
// ─────────────────────────────────────────────────────────────────────────────

class ApiConfig {
  // ── Change this to your server URL ──────────────────────────────────────────
  static const String baseUrl = 'http://10.0.2.2:8000';

  // ── Endpoints ────────────────────────────────────────────────────────────────
  static const String register      = '$baseUrl/auth/register';
  static const String login         = '$baseUrl/auth/login';
  static String profile(int userId) => '$baseUrl/auth/profile/$userId';

  static String vitals(int userId)        => '$baseUrl/vitals/$userId';
  static String vitalsLatest(int userId)  => '$baseUrl/vitals/$userId/latest';
  static String vitalsHistory(int userId) => '$baseUrl/vitals/$userId/history';

  static String medications(int userId)                      => '$baseUrl/medications/$userId';
  static String medication(int userId, int medId)            => '$baseUrl/medications/$userId/$medId';

  static const String chatbot = '$baseUrl/chatbot/';
  static const String health  = '$baseUrl/health';

  /// Timeout for every request.
  static const Duration timeout = Duration(seconds: 60);
}
