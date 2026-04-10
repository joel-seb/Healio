import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healio/models/notification.dart';

void main() {
  group('AppNotification.timeAgo', () {
    test('"Just now" for timestamps under 1 minute ago', () {
      final n = AppNotification(
        id: '1', title: 'Test', message: '',
        type: NotificationType.medication,
        timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
        icon: Icons.medication, color: Colors.teal,
      );
      expect(n.timeAgo, 'Just now');
    });

    test('minutes ago format for 1–59 minutes', () {
      final n = AppNotification(
        id: '1', title: 'Test', message: '',
        type: NotificationType.medication,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        icon: Icons.medication, color: Colors.teal,
      );
      expect(n.timeAgo, '15m ago');
    });

    test('hours ago format for 1–23 hours', () {
      final n = AppNotification(
        id: '1', title: 'Test', message: '',
        type: NotificationType.medication,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        icon: Icons.medication, color: Colors.teal,
      );
      expect(n.timeAgo, '3h ago');
    });

    test('days ago format for 1–6 days', () {
      final n = AppNotification(
        id: '1', title: 'Test', message: '',
        type: NotificationType.medication,
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
        icon: Icons.medication, color: Colors.teal,
      );
      expect(n.timeAgo, '4d ago');
    });
  });

  group('AppNotification.isRead', () {
    test('defaults to false', () {
      final n = AppNotification(
        id: '1', title: 'Test', message: '',
        type: NotificationType.medication,
        timestamp: DateTime.now(),
        icon: Icons.medication, color: Colors.teal,
      );
      expect(n.isRead, isFalse);
    });

    test('can be set to true', () {
      final n = AppNotification(
        id: '1', title: 'Test', message: '',
        type: NotificationType.medication,
        timestamp: DateTime.now(),
        isRead: true,
        icon: Icons.medication, color: Colors.teal,
      );
      expect(n.isRead, isTrue);
    });
  });

  group('AppNotification.getIconForType', () {
    test('medication type returns medication icon', () {
      expect(AppNotification.getIconForType(NotificationType.medication), Icons.medication);
    });

    test('vitals type returns favorite icon', () {
      expect(AppNotification.getIconForType(NotificationType.vitals), Icons.favorite);
    });

    test('appointment type returns calendar icon', () {
      expect(AppNotification.getIconForType(NotificationType.appointment), Icons.calendar_today);
    });
  });

  group('AppNotification.getColorForType', () {
    test('medication type returns teal color', () {
      expect(
        AppNotification.getColorForType(NotificationType.medication),
        const Color(0xFF20B2AA),
      );
    });

    test('vitals type returns red color', () {
      expect(
        AppNotification.getColorForType(NotificationType.vitals),
        const Color(0xFFFF6B6B),
      );
    });
  });
}
