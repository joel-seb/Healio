import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/medication.dart';

// Top-level handler — MUST be outside the class and declared before everything
@pragma('vm:entry-point')
void _bgHandler(NotificationResponse response) {}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Callback for when user taps a notification
  void Function(String? payload)? _onTap;
  void setOnNotificationTap(void Function(String? payload) callback) {
    _onTap = callback;
  }

  // ── Initialize ─────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 1. Set up timezone correctly
      tz.initializeTimeZones();
      String localTimezone = 'Asia/Kolkata'; // safe default for India
      try {
        localTimezone = await FlutterTimezone.getLocalTimezone();
      } catch (_) {}

      const Map<String, String> timezoneAliases = {
        'Asia/Calcutta': 'Asia/Kolkata',
        'Asia/Katmandu': 'Asia/Kathmandu',
        'Asia/Rangoon': 'Asia/Yangon',
        'Atlantic/Faeroe': 'Atlantic/Faroe',
        'Pacific/Ponape': 'Pacific/Pohnpei',
        'Pacific/Truk': 'Pacific/Chuuk',
      };
      localTimezone = timezoneAliases[localTimezone] ?? localTimezone;

      try {
        tz.setLocalLocation(tz.getLocation(localTimezone));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      }

      // 2. Android: create the notification channels
      if (Platform.isAndroid) {
        final androidPlugin = _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        await androidPlugin?.createNotificationChannel(
          const AndroidNotificationChannel(
            'medication_reminders',
            'Medication Reminders',
            description: 'Reminds you to take your medications on time',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          ),
        );

        await androidPlugin?.createNotificationChannel(
          const AndroidNotificationChannel(
            'missed_medications',
            'Missed Medications',
            description: 'Alerts for missed medication doses',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          ),
        );
      }

      // 3. Initialise the plugin
      const androidSettings =
          AndroidInitializationSettings('@drawable/ic_notification');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _notifications.initialize(
        const InitializationSettings(android: androidSettings, iOS: iosSettings),
        onDidReceiveNotificationResponse: (NotificationResponse r) {
          // User tapped notification while app is open or in foreground
          _onTap?.call(r.payload);
        },
        onDidReceiveBackgroundNotificationResponse: _bgHandler,
      );

      // Handle tap when app was launched FROM a notification (cold start)
      final launchDetails = await _notifications.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp == true) {
        final payload = launchDetails?.notificationResponse?.payload;
        Future.delayed(const Duration(milliseconds: 500), () {
          _onTap?.call(payload);
        });
      }

      _initialized = true;
    } catch (e) {
      // Don't crash the app if notification init fails
      _initialized = true;
    }
  }

  // ── Request all required permissions ──────────────────────────────────────

  Future<void> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.requestNotificationsPermission();
        // Try to request exact alarms — won't crash if denied
        try {
          await androidPlugin?.requestExactAlarmsPermission();
        } catch (_) {}
      } else if (Platform.isIOS) {
        final iosPlugin = _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        await iosPlugin?.requestPermissions(
            alert: true, badge: true, sound: true);
      }
    } catch (_) {}
  }

  // ── Notification detail builders ───────────────────────────────────────────

  NotificationDetails _reminderDetails(Medication med) {
    final body = 'Take ${med.dose} now'
        '${med.instructions != null ? ' · ${med.instructions}' : ''}';
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'medication_reminders',
        'Medication Reminders',
        channelDescription: 'Reminds you to take your medications on time',
        importance: Importance.max,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        icon: '@drawable/ic_notification',
        color: const Color(0xFF20B2AA),
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(body),
        timeoutAfter: 60000,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  // ── Schedule a single medication reminder ──────────────────────────────────

  Future<void> scheduleMedicationReminder(
      Medication medication, String time) async {
    await initialize();

    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final notifId = (medication.id.hashCode.abs() + hour * 60 + minute) % 2147483647;

      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
          tz.local, now.year, now.month, now.day, hour, minute);

      // If saved within same minute, fire immediately
      final diffSeconds = now.difference(scheduled).inSeconds;
      if (diffSeconds >= 0 && diffSeconds <= 120) {
        await _notifications.show(
          notifId,
          '💊 Time for ${medication.name}',
          'Take ${medication.dose} now'
              '${medication.instructions != null ? ' · ${medication.instructions}' : ''}',
          _reminderDetails(medication),
          payload: '${medication.id}:$time',
        );
        return;
      }

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      // Try exact alarm first, fall back to inexact if permission denied
      // This prevents crash on OnePlus/Xiaomi with battery optimization
      try {
        await _notifications.zonedSchedule(
          notifId,
          '💊 Time for ${medication.name}',
          'Take ${medication.dose} now'
              '${medication.instructions != null ? ' · ${medication.instructions}' : ''}',
          scheduled,
          _reminderDetails(medication),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: '${medication.id}:$time',
        );
      } catch (_) {
        // Fallback: use inexact alarm (won't crash, slightly less precise)
        await _notifications.zonedSchedule(
          notifId,
          '💊 Time for ${medication.name}',
          'Take ${medication.dose} now'
              '${medication.instructions != null ? ' · ${medication.instructions}' : ''}',
          scheduled,
          _reminderDetails(medication),
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: '${medication.id}:$time',
        );
      }
    } catch (_) {
      // Never crash the app due to notification scheduling failure
    }
  }

  Future<void> scheduleAllMedications(List<Medication> medications) async {
    await initialize();
    await cancelAllNotifications();
    for (final med in medications) {
      for (final time in med.times) {
        try {
          await scheduleMedicationReminder(med, time);
        } catch (_) {}
      }
    }
  }

  /// Call this after user marks a dose as taken.
  /// Cancels today notification and schedules fresh one for tomorrow.
  Future<void> rescheduleMedicationForTomorrow(
      Medication medication, String time) async {
    await initialize();
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final notifId =
          (medication.id.hashCode.abs() + hour * 60 + minute) % 2147483647;

      // Cancel pending alarm AND dismiss delivered notification from tray
      await _notifications.cancel(notifId);
      await _notifications.cancel(notifId + 1);
      await _notifications.cancel(notifId - 1);

      // Schedule for tomorrow
      final now = tz.TZDateTime.now(tz.local);
      final tomorrow = tz.TZDateTime(
          tz.local, now.year, now.month, now.day + 1, hour, minute);

      try {
        await _notifications.zonedSchedule(
          notifId,
          '💊 Time for ${medication.name}',
          'Take ${medication.dose} now'
              '${medication.instructions != null ? ' · ${medication.instructions}' : ''}',
          tomorrow,
          _reminderDetails(medication),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: '${medication.id}:$time',
        );
      } catch (_) {
        await _notifications.zonedSchedule(
          notifId,
          '💊 Time for ${medication.name}',
          'Take ${medication.dose} now'
              '${medication.instructions != null ? ' · ${medication.instructions}' : ''}',
          tomorrow,
          _reminderDetails(medication),
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: '${medication.id}:$time',
        );
      }
    } catch (_) {}
  }

  // ── Instant notifications ─────────────────────────────────────────────────

  Future<void> showMissedMedicationNotification(MedicationDose dose) async {
    await initialize();
    try {
      await _notifications.show(
        (dose.medicationId.hashCode + dose.time.hashCode).abs() % 2147483647,
        '⚠️ Missed: ${dose.medicationName}',
        'You missed your ${dose.dose} at ${dose.time}',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'missed_medications', 'Missed Medications',
            channelDescription: 'Alerts for missed medication doses',
            importance: Importance.max,
            priority: Priority.high,
            visibility: NotificationVisibility.public,
            color: const Color(0xFFFF6B6B),
            icon: '@drawable/ic_notification',
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        payload: '${dose.medicationId}:missed',
      );
    } catch (_) {}
  }

  Future<void> showUpcomingReminder(MedicationDose dose) async {
    await initialize();
    try {
      await _notifications.show(
        (dose.medicationId.hashCode + dose.time.hashCode + 1000).abs() %
            2147483647,
        '🔔 Upcoming: ${dose.medicationName}',
        'Reminder: Take ${dose.dose} at ${dose.time}',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminders', 'Medication Reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            visibility: NotificationVisibility.public,
            color: const Color(0xFF20B2AA),
            icon: '@drawable/ic_notification',
          ),
          iOS: const DarwinNotificationDetails(
              presentAlert: true, presentBadge: true, presentSound: true),
        ),
        payload: '${dose.medicationId}:upcoming',
      );
    } catch (_) {}
  }

  // ── Cancel helpers ─────────────────────────────────────────────────────────

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (_) {}
  }

  Future<void> cancelDoseNotification(String medicationId, String time) async {
    try {
      final parts = time.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      final id =
          (medicationId.hashCode.abs() + hour * 60 + minute) % 2147483647;
      // Cancel both pending scheduled alarm AND already-delivered notification in tray
      await _notifications.cancel(id);
      // Also cancel with slight ID variations in case of delivery ID drift
      await _notifications.cancel(id + 1);
      await _notifications.cancel(id - 1);
    } catch (_) {}
  }

  Future<void> cancelMedicationNotifications(Medication medication) async {
    try {
      for (final time in medication.times) {
        final parts = time.split(':');
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
        final id = (medication.id.hashCode.abs() + hour * 60 + minute) % 2147483647;
        await _notifications.cancel(id);
      }
    } catch (_) {}
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (_) {
      return [];
    }
  }
}
