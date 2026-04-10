import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../screens/user_data.dart';

/// AuthService — tries the backend first, falls back to local SharedPreferences.
/// After a successful backend login the token and userId are stored locally so
/// the session survives app restarts even without network.
class AuthService extends ChangeNotifier {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  static const _sessionKey = 'session_email';
  static const _usersKey   = 'registered_users';
  static const _tokenKey   = 'backend_token';
  static const _backendIdKey = 'backend_user_id';

  final _api = ApiService();

  UserData? _userData;
  bool _isLoading = false;

  UserData? get userData  => _userData;
  bool get isLoading      => _isLoading;
  bool get isLoggedIn     => _userData != null;

  // ── Local helpers ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return {};
    return Map<String, dynamic>.from(jsonDecode(raw));
  }

  Future<void> _saveUsers(Map<String, dynamic> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<void> _persistSession(UserData u, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, u.email);
    if (u.token != null) await prefs.setString(_tokenKey, u.token!);
    if (u.backendId != null) await prefs.setInt(_backendIdKey, u.backendId!);

    final users = await _loadUsers();
    users[u.email] = _toMap(u, password);
    await _saveUsers(users);
  }

  // ── Session restore ───────────────────────────────────────────────────────

  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_sessionKey);
    if (email == null) return false;

    final users = await _loadUsers();
    final raw = users[email];
    if (raw == null) return false;

    final stored = Map<String, dynamic>.from(raw);

    // Reload stored token into ApiService
    final storedToken = prefs.getString(_tokenKey);
    final storedBackendId = prefs.getInt(_backendIdKey);
    if (storedToken != null) _api.setToken(storedToken);

    _userData = _fromMap(stored).copyWith(
      token: storedToken,
      backendId: storedBackendId,
    );
    notifyListeners();
    return true;
  }

  // ── Register ──────────────────────────────────────────────────────────────

  Future<UserData> register({
    required String name, required int age, required String email,
    required String password, String bloodType = 'O+',
    double? height, double? weight,
  }) async {
    _isLoading = true; notifyListeners();

    try {
      // Try backend first
      if (await _api.isBackendReachable()) {
        final data = await _api.register(
          name: name, age: age, email: email, password: password,
          bloodType: bloodType, height: height, weight: weight,
        );
        final user = data['user'] as Map<String, dynamic>;
        _userData = UserData(
          name: user['name'] ?? name, email: email,
          bloodType: user['blood_type'] ?? bloodType,
          age: user['age'] ?? age,
          height: (user['height'] ?? height ?? 170.0).toDouble(),
          weight: (user['weight'] ?? weight ?? 70.0).toDouble(),
          backendId: data['user_id'] as int?,
          token: data['token'] as String?,
        );
        await _persistSession(_userData!, password);
        notifyListeners();
        return _userData!;
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 400) rethrow; // duplicate email
      // other errors → fall through to local registration
    }

    // Offline fallback
    final users = await _loadUsers();
    if (users.containsKey(email)) {
      throw ApiException('An account with this email already exists.');
    }
    _userData = UserData(
      name: name, email: email, bloodType: bloodType,
      age: age, height: height ?? 170.0, weight: weight ?? 70.0,
    );
    await _persistSession(_userData!, password);
    notifyListeners();
    return _userData!;
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<UserData> login(String email, String password) async {
    _isLoading = true; notifyListeners();

    try {
      // Try backend first
      if (await _api.isBackendReachable()) {
        final data = await _api.login(email: email, password: password);
        final user = data['user'] as Map<String, dynamic>;
        _userData = UserData(
          name: user['name'] ?? '', email: email,
          bloodType: user['blood_type'] ?? 'O+',
          age: user['age'] ?? 0,
          height: (user['height'] ?? 170.0).toDouble(),
          weight: (user['weight'] ?? 70.0).toDouble(),
          backendId: data['user_id'] as int?,
          token: data['token'] as String?,
        );
        await _persistSession(_userData!, password);
        notifyListeners();
        return _userData!;
      }
    } catch (e) {
      if (e is ApiException && (e.statusCode == 401 || e.statusCode == 400)) {
        rethrow; // Wrong credentials — don't fall through
      }
    }

    // Offline fallback
    final users = await _loadUsers();
    final raw = users[email];
    if (raw == null) throw ApiException('No account found with this email.');
    final stored = Map<String, dynamic>.from(raw);
    if (stored['password'] != password) {
      throw ApiException('Incorrect password. Please try again.');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, email);
    _userData = _fromMap(stored).copyWith(
      token: prefs.getString(_tokenKey),
      backendId: prefs.getInt(_backendIdKey),
    );
    if (_userData!.token != null) _api.setToken(_userData!.token!);
    notifyListeners();
    return _userData!;
  }

  // ── Update profile ────────────────────────────────────────────────────────

  Future<UserData> updateProfile(UserData updated) async {
    final email = _userData?.email ?? updated.email;
    final users = await _loadUsers();
    final stored = Map<String, dynamic>.from(users[email] ?? {});
    final password = stored['password'] ?? '';

    final merged = (_userData ?? updated).copyWith(
      name: updated.name, email: updated.email,
      bloodType: updated.bloodType, age: updated.age,
      height: updated.height, weight: updated.weight,
    );

    // Try backend update
    final backendId = merged.backendId;
    if (backendId != null) {
      try {
        await _api.updateProfile(backendId,
          name: merged.name, age: merged.age,
          bloodType: merged.bloodType,
          height: merged.height, weight: merged.weight,
        );
      } catch (_) {
        // Backend failed — local update still proceeds
      }
    }

    users[email] = _toMap(merged, password);
    await _saveUsers(users);
    _userData = merged;
    notifyListeners();
    return _userData!;
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_backendIdKey);
    _api.clearToken();
    _userData = null;
    notifyListeners();
  }

  void updateLocalVitals(UserData vitals) {
    if (_userData == null) return;
    _userData = _userData!.copyWith(
      heartRate: vitals.heartRate, systolic: vitals.systolic,
      diastolic: vitals.diastolic, bloodSugar: vitals.bloodSugar,
      bodyTemp: vitals.bodyTemp, spo2: vitals.spo2,
    );
    notifyListeners();
  }

  // ── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> _toMap(UserData u, String password) => {
    'name': u.name, 'email': u.email, 'blood_type': u.bloodType,
    'age': u.age, 'height': u.height, 'weight': u.weight,
    'password': password,
    if (u.backendId != null) 'backend_id': u.backendId,
  };

  UserData _fromMap(Map<String, dynamic> m) => UserData(
    name: m['name'] ?? 'User', email: m['email'] ?? '',
    bloodType: m['blood_type'] ?? 'O+', age: m['age'] ?? 0,
    height: (m['height'] ?? 170.0).toDouble(),
    weight: (m['weight'] ?? 70.0).toDouble(),
    backendId: m['backend_id'] as int?,
  );
}
