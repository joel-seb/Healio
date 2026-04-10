import 'package:flutter/material.dart';
import '../models/notification.dart';

class NotificationsManager {
  static final NotificationsManager _instance = NotificationsManager._internal();
  factory NotificationsManager() => _instance;
  NotificationsManager._internal();

  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications {
    final sorted = List<AppNotification>.from(_notifications);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  final List<VoidCallback> _listeners = [];
  void addListener(VoidCallback l) => _listeners.add(l);
  void removeListener(VoidCallback l) => _listeners.remove(l);
  void _notify() { for (final l in _listeners) l(); }

  int get count => _notifications.length;

  void addMedicationReminder({required String medicationName, required String dose, required String time}) {
    _notifications.add(AppNotification(
      id: '${medicationName}_${time}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Time to take $medicationName',
      message: 'Take $dose at $time',
      type: NotificationType.medication,
      timestamp: DateTime.now(),
      icon: Icons.medication,
      color: const Color(0xFF20B2AA),
    ));
    _notify();
  }

  void addMissedDoseAlert({required String medicationName, required String dose, required String time}) {
    final exists = _notifications.any((n) =>
        n.title.contains('Missed') && n.message.toLowerCase().contains(medicationName.toLowerCase()));
    if (exists) return;
    _notifications.add(AppNotification(
      id: 'missed_${medicationName}_${time}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Missed dose – $medicationName',
      message: '$dose was scheduled for $time',
      type: NotificationType.medication,
      timestamp: DateTime.now(),
      icon: Icons.warning_amber_rounded,
      color: const Color(0xFFFF6B6B),
    ));
    _notify();
  }

  void addTakenConfirmation({required String medicationName, required String dose}) {
    _notifications.add(AppNotification(
      id: 'taken_${medicationName}_${DateTime.now().millisecondsSinceEpoch}',
      title: '$medicationName taken ✓',
      message: '$dose marked as taken',
      type: NotificationType.medication,
      timestamp: DateTime.now(),
      icon: Icons.check_circle,
      color: const Color(0xFF20B2AA),
    ));
    _notify();
  }

  void addMedicationAddedAlert({required String medicationName, required String dose}) {
    _notifications.add(AppNotification(
      id: 'added_${medicationName}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Medication added',
      message: '$medicationName ($dose) added to your schedule',
      type: NotificationType.medication,
      timestamp: DateTime.now(),
      icon: Icons.add_circle,
      color: const Color(0xFF20B2AA),
    ));
    _notify();
  }

  void removeNotificationForMedication(String medicationName) {
    _notifications.removeWhere((n) =>
        n.title.toLowerCase().contains(medicationName.toLowerCase()) ||
        n.message.toLowerCase().contains(medicationName.toLowerCase()));
    _notify();
  }

  /// Removes only "Time to take" or "Missed" alerts for a specific dose,
  /// without removing taken confirmations or other notifications.
  void removeDoseAlert(String medicationName, String time) {
    _notifications.removeWhere((n) {
      final titleLower = n.title.toLowerCase();
      final msgLower = n.message.toLowerCase();
      final nameMatch = titleLower.contains(medicationName.toLowerCase()) ||
          msgLower.contains(medicationName.toLowerCase());
      final isAlert = titleLower.contains('time to take') ||
          titleLower.contains('missed') ||
          titleLower.contains('time for');
      return nameMatch && isAlert;
    });
    _notify();
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _notify();
  }

  void clearAll() {
    _notifications.clear();
    _notify();
  }
}
