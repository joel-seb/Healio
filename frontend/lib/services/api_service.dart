import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ApiException — used everywhere a backend error needs to be surfaced to UI
// ─────────────────────────────────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

// ─────────────────────────────────────────────────────────────────────────────
//  ApiService — singleton HTTP client wrapping every backend endpoint
// ─────────────────────────────────────────────────────────────────────────────
class ApiService {
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  String? _token;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;
  bool get hasToken => _token != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<bool> isBackendReachable() async {
    try {
      final res = await http
          .get(Uri.parse(ApiConfig.health), headers: _headers)
          .timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _decode(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    String detail = 'Server error (${res.statusCode})';
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      detail = body['detail']?.toString() ?? detail;
    } catch (_) {}
    throw ApiException(detail, statusCode: res.statusCode);
  }

  List<dynamic> _decodeList(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    String detail = 'Server error (${res.statusCode})';
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      detail = body['detail']?.toString() ?? detail;
    } catch (_) {}
    throw ApiException(detail, statusCode: res.statusCode);
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String name, required int age, required String email,
    required String password, String bloodType = 'O+',
    double? height, double? weight,
  }) async {
    try {
      final res = await http.post(Uri.parse(ApiConfig.register),
          headers: _headers,
          body: jsonEncode({'name': name, 'age': age, 'email': email,
            'password': password, 'blood_type': bloodType,
            if (height != null) 'height': height,
            if (weight != null) 'weight': weight}))
          .timeout(ApiConfig.timeout);
      final data = _decode(res);
      _token = data['token'] as String?;
      return data;
    } on SocketException {
      throw ApiException('No internet connection.');
    } on ApiException { rethrow; } catch (e) { throw ApiException('$e'); }
  }

  Future<Map<String, dynamic>> login({
    required String email, required String password,
  }) async {
    try {
      final res = await http.post(Uri.parse(ApiConfig.login),
          headers: _headers,
          body: jsonEncode({'email': email, 'password': password}))
          .timeout(ApiConfig.timeout);
      final data = _decode(res);
      _token = data['token'] as String?;
      return data;
    } on SocketException {
      throw ApiException('No internet connection.');
    } on ApiException { rethrow; } catch (e) { throw ApiException('$e'); }
  }

  Future<Map<String, dynamic>> getProfile(int userId) async {
    try {
      final res = await http.get(Uri.parse(ApiConfig.profile(userId)), headers: _headers)
          .timeout(ApiConfig.timeout);
      return _decode(res);
    } on ApiException { rethrow; } catch (e) { throw ApiException('$e'); }
  }

  Future<Map<String, dynamic>> updateProfile(int userId, {
    String? name, int? age, String? bloodType, double? height, double? weight,
  }) async {
    try {
      final res = await http.put(Uri.parse(ApiConfig.profile(userId)),
          headers: _headers,
          body: jsonEncode({
            if (name != null) 'name': name, if (age != null) 'age': age,
            if (bloodType != null) 'blood_type': bloodType,
            if (height != null) 'height': height, if (weight != null) 'weight': weight,
          })).timeout(ApiConfig.timeout);
      return _decode(res);
    } on ApiException { rethrow; } catch (e) { throw ApiException('$e'); }
  }

  // ── Vitals ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> saveVitals(int userId, {
    int? heartRate, int? systolic, int? diastolic,
    double? bloodSugar, double? postMealSugar, double? bodyTemp, int? spo2,
  }) async {
    try {
      final res = await http.post(Uri.parse(ApiConfig.vitals(userId)),
          headers: _headers,
          body: jsonEncode({
            if (heartRate != null) 'heart_rate': heartRate,
            if (systolic != null) 'systolic': systolic,
            if (diastolic != null) 'diastolic': diastolic,
            if (bloodSugar != null) 'blood_sugar': bloodSugar,
            if (postMealSugar != null) 'post_meal_sugar': postMealSugar,
            if (bodyTemp != null) 'body_temp': bodyTemp,
            if (spo2 != null) 'spo2': spo2,
          })).timeout(ApiConfig.timeout);
      return _decode(res);
    } on ApiException { rethrow; } catch (e) { throw ApiException('$e'); }
  }

  Future<Map<String, dynamic>> getLatestVitals(int userId) async {
    try {
      final res = await http.get(Uri.parse(ApiConfig.vitalsLatest(userId)), headers: _headers)
          .timeout(ApiConfig.timeout);
      return _decode(res);
    } on ApiException { rethrow; } catch (e) { throw ApiException('$e'); }
  }

  Future<List<dynamic>> getVitalsHistory(int userId, {int limit = 20}) async {
    try {
      final res = await http.get(Uri.parse('${ApiConfig.vitalsHistory(userId)}?limit=$limit'),
          headers: _headers).timeout(ApiConfig.timeout);
      return _decodeList(res);
    } on ApiException { rethrow; } catch (e) { throw ApiException('$e'); }
  }

  // ── Medications ───────────────────────────────────────────────────────────

  Future<List<dynamic>> getMedications(int userId) async {
    try {
      final res = await http.get(Uri.parse(ApiConfig.medications(userId)), headers: _headers)
          .timeout(ApiConfig.timeout);
      return _decodeList(res);
    } on ApiException { rethrow; } catch (e) { throw ApiException('$e'); }
  }

  Future<Map<String, dynamic>> addMedication(int userId, {
    required String name, String? dose, List<String>? times,
    String? startDate, String? endDate, String? prescribedBy,
    String? instructions, String? notes, String iconColor = '0xFF20B2AA',
  }) async {
    try {
      final res = await http.post(Uri.parse(ApiConfig.medications(userId)),
          headers: _headers,
          body: jsonEncode({
            'name': name, if (dose != null) 'dose': dose,
            if (times != null) 'times': times,
            if (startDate != null) 'start_date': startDate,
            if (endDate != null) 'end_date': endDate,
            if (prescribedBy != null) 'prescribed_by': prescribedBy,
            if (instructions != null) 'instructions': instructions,
            if (notes != null) 'notes': notes, 'icon_color': iconColor,
          })).timeout(ApiConfig.timeout);
      return _decode(res);
    } on ApiException { rethrow; } catch (e) { throw ApiException('$e'); }
  }

  Future<Map<String, dynamic>> updateMedication(int userId, int medId, {
    required String name, String? dose, List<String>? times,
    String? startDate, String? endDate, String? prescribedBy,
    String? instructions, String? notes, String iconColor = '0xFF20B2AA',
  }) async {
    try {
      final res = await http.put(Uri.parse(ApiConfig.medication(userId, medId)),
          headers: _headers,
          body: jsonEncode({
            'name': name, if (dose != null) 'dose': dose,
            if (times != null) 'times': times,
            if (startDate != null) 'start_date': startDate,
            if (endDate != null) 'end_date': endDate,
            if (prescribedBy != null) 'prescribed_by': prescribedBy,
            if (instructions != null) 'instructions': instructions,
            if (notes != null) 'notes': notes, 'icon_color': iconColor,
          })).timeout(ApiConfig.timeout);
      return _decode(res);
    } on ApiException { rethrow; } catch (e) { throw ApiException('$e'); }
  }

  Future<void> deleteMedication(int userId, int medId) async {
    try {
      final res = await http.delete(Uri.parse(ApiConfig.medication(userId, medId)),
          headers: _headers).timeout(ApiConfig.timeout);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        String detail = 'Delete failed (${res.statusCode})';
        try { detail = (jsonDecode(res.body) as Map)['detail']?.toString() ?? detail; } catch (_) {}
        throw ApiException(detail);
      }
    } on ApiException { rethrow; } catch (e) { throw ApiException('$e'); }
  }

  // ── Chatbot ───────────────────────────────────────────────────────────────

  /// POST /chatbot/  — 15 s timeout because ML inference can be slow
  Future<String> sendChatMessage(String message) async {
    try {
      final res = await http.post(Uri.parse(ApiConfig.chatbot),
          headers: _headers,
          body: jsonEncode({'message': message}))
          .timeout(const Duration(seconds: 15));
      final data = _decode(res);
      return data['response']?.toString() ?? 'No response received.';
    } on ApiException { rethrow; } catch (e) {
      throw ApiException('Chat service unavailable. Please try again.');
    }
  }
}
