import 'package:flutter/material.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Saves vitals to the backend. Silently ignores errors so the UI
/// is never blocked — vitals are already stored locally in UserData.
Future<void> saveVitalsToBackend({
  int? heartRate, int? systolic, int? diastolic,
  double? bloodSugar, double? postMealSugar, double? bodyTemp, int? spo2,
}) async {
  final userId = AuthService().userData?.backendId;
  if (userId == null) return; // offline / not logged into backend

  try {
    await ApiService().saveVitals(
      userId,
      heartRate: heartRate, systolic: systolic, diastolic: diastolic,
      bloodSugar: bloodSugar, postMealSugar: postMealSugar, bodyTemp: bodyTemp, spo2: spo2,
    );
  } catch (_) {
    // Silent fail — vitals are persisted locally regardless
  }
}

/// Loads the latest vitals from the backend and merges into local UserData.
/// Returns true if data was loaded, false if offline/unavailable.
Future<bool> loadLatestVitalsFromBackend() async {
  final auth = AuthService();
  final userId = auth.userData?.backendId;
  if (userId == null) return false;

  try {
    final data = await ApiService().getLatestVitals(userId);
    // Merge into local UserData without overwriting null fields
    final current = auth.userData!;
    auth.updateLocalVitals(current.copyWith(
      heartRate:  data['heart_rate'] as int?   ?? current.heartRate,
      systolic:   data['systolic']   as int?   ?? current.systolic,
      diastolic:  data['diastolic']  as int?   ?? current.diastolic,
      bloodSugar: (data['blood_sugar'] as num?)?.toDouble() ?? current.bloodSugar,
      postMealSugar: (data['post_meal_sugar'] as num?)?.toDouble() ?? current.postMealSugar,
      bodyTemp:   (data['body_temp']   as num?)?.toDouble() ?? current.bodyTemp,
      spo2:       data['spo2']        as int?  ?? current.spo2,
    ));
    return true;
  } catch (_) {
    return false;
  }
}

/// SnackBar helper shown after saving vitals.
void showVitalsSaved(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Vitals saved ✓'),
      backgroundColor: Color(0xFF20B2AA),
      duration: Duration(seconds: 2),
    ),
  );
}
