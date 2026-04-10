import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healio/models/notification.dart';
import 'package:healio/services/notifications_manager.dart';

AppNotification _makeNotification({
  required String id,
  required String title,
  String message = '',
}) {
  return AppNotification(
    id: id,
    title: title,
    message: message,
    type: NotificationType.medication,
    timestamp: DateTime.now(),
    icon: Icons.medication,
    color: const Color(0xFF20B2AA),
  );
}

void main() {
  // Reset singleton state before each test so tests don't bleed into each other.
  setUp(() {
    NotificationsManager().notifications.clear();
  });

  group('NotificationsManager.count', () {
    test('returns 0 when list is empty', () {
      expect(NotificationsManager().count, 0);
    });

    test('reflects notifications added directly', () {
      NotificationsManager().notifications.addAll([
        _makeNotification(id: '1', title: 'A'),
        _makeNotification(id: '2', title: 'B'),
      ]);
      expect(NotificationsManager().count, 2);
    });
  });

  group('NotificationsManager.removeNotification', () {
    test('removes notification with matching id', () {
      NotificationsManager().notifications.add(
        _makeNotification(id: 'abc', title: 'Take Aspirin'),
      );
      NotificationsManager().removeNotification('abc');
      expect(NotificationsManager().count, 0);
    });

    test('does not remove notification with different id', () {
      NotificationsManager().notifications.add(
        _makeNotification(id: 'abc', title: 'Take Aspirin'),
      );
      NotificationsManager().removeNotification('xyz');
      expect(NotificationsManager().count, 1);
    });
  });

  group('NotificationsManager.removeNotificationForMedication', () {
    test('removes notification whose title contains the medication name', () {
      NotificationsManager().notifications.add(
        _makeNotification(id: '1', title: 'Time to take Aspirin'),
      );
      NotificationsManager().removeNotificationForMedication('Aspirin');
      expect(NotificationsManager().count, 0);
    });

    test('removes notification whose message contains the medication name', () {
      NotificationsManager().notifications.add(
        _makeNotification(id: '1', title: 'Reminder', message: 'Metformin - 500mg due'),
      );
      NotificationsManager().removeNotificationForMedication('Metformin');
      expect(NotificationsManager().count, 0);
    });

    test('is case-insensitive', () {
      NotificationsManager().notifications.add(
        _makeNotification(id: '1', title: 'Take LISINOPRIL now'),
      );
      NotificationsManager().removeNotificationForMedication('lisinopril');
      expect(NotificationsManager().count, 0);
    });

    test('leaves unrelated notifications untouched', () {
      NotificationsManager().notifications.addAll([
        _makeNotification(id: '1', title: 'Take Aspirin'),
        _makeNotification(id: '2', title: 'Take Metformin'),
      ]);
      NotificationsManager().removeNotificationForMedication('Aspirin');
      expect(NotificationsManager().count, 1);
      expect(NotificationsManager().notifications.first.id, '2');
    });
  });

  group('NotificationsManager.clearAll', () {
    test('empties the list', () {
      NotificationsManager().notifications.addAll([
        _makeNotification(id: '1', title: 'A'),
        _makeNotification(id: '2', title: 'B'),
        _makeNotification(id: '3', title: 'C'),
      ]);
      NotificationsManager().clearAll();
      expect(NotificationsManager().count, 0);
    });

    test('is safe to call on an already-empty list', () {
      expect(() => NotificationsManager().clearAll(), returnsNormally);
      expect(NotificationsManager().count, 0);
    });
  });

  group('NotificationsManager listeners', () {
    test('listener is called when removeNotification fires', () {
      bool called = false;
      NotificationsManager().notifications.add(
        _makeNotification(id: '1', title: 'A'),
      );
      NotificationsManager().addListener(() => called = true);
      NotificationsManager().removeNotification('1');
      expect(called, isTrue);
    });

    test('listener is called when clearAll fires', () {
      bool called = false;
      NotificationsManager().addListener(() => called = true);
      NotificationsManager().clearAll();
      expect(called, isTrue);
    });

    test('removed listener is NOT called', () {
      bool called = false;
      void listener() => called = true;
      NotificationsManager().addListener(listener);
      NotificationsManager().removeListener(listener);
      NotificationsManager().clearAll();
      expect(called, isFalse);
    });

    test('multiple listeners all receive the notification', () {
      int callCount = 0;
      NotificationsManager().addListener(() => callCount++);
      NotificationsManager().addListener(() => callCount++);
      NotificationsManager().clearAll();
      expect(callCount, 2);
    });
  });

  group('NotificationsManager singleton', () {
    test('two instances share the same state', () {
      final a = NotificationsManager();
      final b = NotificationsManager();
      a.notifications.add(_makeNotification(id: '1', title: 'A'));
      expect(b.count, 1);
    });
  });
}
