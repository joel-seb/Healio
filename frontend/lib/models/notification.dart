import 'package:flutter/material.dart';

enum NotificationType {
  medication,
  vitals,
  appointment,
  healthTip,
  reminder,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  bool isRead;
  final IconData icon;
  final Color color;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    required this.icon,
    required this.color,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  static IconData getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.medication:
        return Icons.medication;
      case NotificationType.vitals:
        return Icons.favorite;
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.healthTip:
        return Icons.tips_and_updates;
      case NotificationType.reminder:
        return Icons.notifications_active;
    }
  }

  static Color getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.medication:
        return const Color(0xFF20B2AA);
      case NotificationType.vitals:
        return const Color(0xFFFF6B6B);
      case NotificationType.appointment:
        return const Color(0xFF7FB3D5);
      case NotificationType.healthTip:
        return const Color(0xFFFFCC80);
      case NotificationType.reminder:
        return const Color(0xFFB39DDB);
    }
  }
}
