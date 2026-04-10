import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// MedicationService — backend-first CRUD.
/// Falls back to local SharedPreferences when the backend is unreachable.
/// Backend int IDs are stored as strings in the local Medication model (id field).
class MedicationService {
  MedicationService._internal();
  static final MedicationService _instance = MedicationService._internal();
  factory MedicationService() => _instance;

  static const _localKey = 'local_medications';

  final _api  = ApiService();
  final _auth = AuthService();

  int? get _userId => _auth.userData?.backendId;

  // ── Fetch ─────────────────────────────────────────────────────────────────

  Future<List<Medication>> fetchMedications() async {
    final userId = _userId;
    if (userId != null) {
      try {
        final list = await _api.getMedications(userId);
        final meds = list
            .map((e) => _fromBackend(e as Map<String, dynamic>))
            .toList();
        // Mirror to local cache so the app works offline afterward
        await _saveLocal(meds);
        return meds;
      } catch (_) {
        // Backend unavailable — fall through to local
      }
    }
    return _fetchLocal();
  }

  // ── Add ───────────────────────────────────────────────────────────────────

  Future<Medication> addMedication(Medication med) async {
    final userId = _userId;
    if (userId != null) {
      // Backend-first: save to server and get back the real ID
      final data = await _api.addMedication(
        userId,
        name: med.name, dose: med.dose.isNotEmpty ? med.dose : null,
        times: med.times,
        startDate: med.startDate.toIso8601String().split('T').first,
        endDate: med.endDate?.toIso8601String().split('T').first,
        prescribedBy: med.prescribedBy,
        instructions: med.instructions, notes: med.notes,
        iconColor: med.iconColor,
      );
      final saved = _fromBackend(data);
      // Keep local cache in sync with backend ID
      final meds = await _fetchLocal();
      meds.add(saved);
      await _saveLocal(meds);
      return saved;
    }

    // Local-only path (no account)
    final meds = await _fetchLocal();
    meds.add(med);
    await _saveLocal(meds);
    return med;
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<Medication> updateMedication(Medication med) async {
    final userId = _userId;
    final backendId = int.tryParse(med.id);
    if (userId != null && backendId != null) {
      // Backend-first update
      final data = await _api.updateMedication(
        userId, backendId,
        name: med.name, dose: med.dose.isNotEmpty ? med.dose : null,
        times: med.times,
        startDate: med.startDate.toIso8601String().split('T').first,
        endDate: med.endDate?.toIso8601String().split('T').first,
        prescribedBy: med.prescribedBy,
        instructions: med.instructions, notes: med.notes,
        iconColor: med.iconColor,
      );
      final updated = _fromBackend(data);
      final meds = await _fetchLocal();
      final idx = meds.indexWhere((m) => m.id == med.id);
      if (idx != -1) meds[idx] = updated;
      await _saveLocal(meds);
      return updated;
    }

    // Local-only fallback
    final meds = await _fetchLocal();
    final idx = meds.indexWhere((m) => m.id == med.id);
    if (idx != -1) meds[idx] = med;
    await _saveLocal(meds);
    return med;
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteMedication(String medicationId) async {
    final userId = _userId;
    final backendId = int.tryParse(medicationId);

    // Always remove from local cache first
    final meds = await _fetchLocal();
    meds.removeWhere((m) => m.id == medicationId);
    await _saveLocal(meds);

    // Then sync to backend — re-throw so the UI knows if it failed
    if (userId != null && backendId != null) {
      await _api.deleteMedication(userId, backendId);
    }
    // If userId or backendId is null, it's a local-only medication — already removed above
  }

  // ── Local cache helpers ───────────────────────────────────────────────────

  Future<List<Medication>> _fetchLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw);
    return list
        .map((e) => Medication.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveLocal(List<Medication> meds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _localKey,
      jsonEncode(meds.map((m) => {...m.toJson(), 'id': m.id}).toList()),
    );
  }

  // ── Backend → Medication converter ───────────────────────────────────────

  Medication _fromBackend(Map<String, dynamic> d) {
    List<String> parseTimes(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return ['08:00'];
    }
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      try { return DateTime.parse(v.toString()); } catch (_) { return DateTime.now(); }
    }
    DateTime? parseDateNullable(dynamic v) {
      if (v == null) return null;
      try { return DateTime.parse(v.toString()); } catch (_) { return null; }
    }
    return Medication(
      id: d['id'].toString(),           // convert backend int → string
      name: d['name'] as String,
      dose: d['dose'] as String? ?? '',
      times: parseTimes(d['times']),
      startDate: parseDate(d['start_date']),
      endDate: parseDateNullable(d['end_date']),
      prescribedBy: d['prescribed_by'] as String?,
      instructions: d['instructions'] as String?,
      notes: d['notes'] as String?,
      iconColor: d['icon_color'] as String? ?? '0xFF20B2AA',
    );
  }
}
