import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists "taken" dose records locally so state survives screen navigation,
/// app restarts, and eventually a backend connection.
///
/// Storage key format:  taken_doses_YYYY-MM-DD
/// Value format:        JSON list of "$medicationId|$time" strings
///
/// Records are automatically pruned after 7 days to avoid stale data.
class DoseTakenService {
  DoseTakenService._();
  static final DoseTakenService instance = DoseTakenService._();

  static const _prefix = 'taken_doses_';

  String _todayKey() {
    final now = DateTime.now();
    return '$_prefix${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _keyForDate(DateTime date) =>
      '$_prefix${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _doseId(String medicationId, String time) => '$medicationId|$time';

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<Set<String>> getTakenDosesForToday() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_todayKey());
    if (raw == null) return {};
    final list = List<String>.from(jsonDecode(raw));
    return list.toSet();
  }

  Future<bool> isDoseTaken(String medicationId, String time) async {
    final taken = await getTakenDosesForToday();
    return taken.contains(_doseId(medicationId, time));
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  Future<void> markTaken(String medicationId, String time) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _todayKey();
    final raw = prefs.getString(key);
    final set = raw != null
        ? Set<String>.from(jsonDecode(raw))
        : <String>{};
    set.add(_doseId(medicationId, time));
    await prefs.setString(key, jsonEncode(set.toList()));
  }

  Future<void> markUntaken(String medicationId, String time) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _todayKey();
    final raw = prefs.getString(key);
    if (raw == null) return;
    final set = Set<String>.from(jsonDecode(raw));
    set.remove(_doseId(medicationId, time));
    await prefs.setString(key, jsonEncode(set.toList()));
  }

  // ── Prune old records (keep last 7 days) ───────────────────────────────────

  Future<void> pruneOldRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final keys = prefs.getKeys()
        .where((k) => k.startsWith(_prefix))
        .toList();
    for (final key in keys) {
      final dateStr = key.replaceFirst(_prefix, '');
      try {
        final date = DateTime.parse(dateStr);
        if (date.isBefore(cutoff)) await prefs.remove(key);
      } catch (_) {
        await prefs.remove(key); // malformed key — remove it
      }
    }
  }
}
