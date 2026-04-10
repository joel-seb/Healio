import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme controller with smooth animations
/// Manages theme state and persistence
class ThemeController extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  bool _isDark = false;

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  ThemeController() {
    _loadTheme();
  }

  /// Load saved theme preference
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDark = prefs.getBool(_themeKey) ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  /// Toggle theme with animation
  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDark);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Set theme explicitly
  Future<void> setTheme(bool isDark) async {
    if (_isDark == isDark) return;
    
    _isDark = isDark;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDark);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}
