import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/notifications_manager.dart';

class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const NotificationsScreen({super.key, this.onBack});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsManager _manager = NotificationsManager();

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onChanged);
  }

  @override
  void dispose() {
    _manager.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _clearAll() {
    if (_manager.notifications.isEmpty) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.delete_sweep, color: Color(0xFFFF6B6B)),
          SizedBox(width: 12),
          Text('Clear All Notifications?'),
        ]),
        content: const Text('This will delete all notifications. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium?.color))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _manager.clearAll();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B), foregroundColor: Colors.white),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _manager.notifications;
    return Column(children: [
        Expanded(
          child: notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  color: const Color(0xFF20B2AA),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: notifications.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text('Notifications',
                              style: TextStyle(
                                  color: Theme.of(context).textTheme.displaySmall?.color,
                                  fontSize: 24, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        );
                      }
                      final notification = notifications[index - 1];
                      return Dismissible(
                        key: Key(notification.id),
                        background: _swipeBg(Alignment.centerLeft),
                        secondaryBackground: _swipeBg(Alignment.centerRight),
                        onDismissed: (_) => _manager.removeNotification(notification.id),
                        child: _buildNotificationCard(notification),
                      );
                    },
                  ),
                ),
        ),
        if (notifications.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _clearAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0),
                child: const Text('Clear All Notifications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
    ]);
  }

  Widget _swipeBg(Alignment alignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFFFF6B6B), borderRadius: BorderRadius.circular(16)),
      alignment: alignment,
      padding: EdgeInsets.only(
          left: alignment == Alignment.centerLeft ? 20 : 0,
          right: alignment == Alignment.centerRight ? 20 : 0),
      child: const Icon(Icons.delete, color: Colors.white, size: 28),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.04),
            blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Material(color: Colors.transparent, child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(padding: const EdgeInsets.all(16), child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                  color: notification.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(notification.icon, color: notification.color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(notification.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color)),
              const SizedBox(height: 4),
              Text(notification.message, style: TextStyle(fontSize: 13,
                  color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.4)),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.access_time, size: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color),
                const SizedBox(width: 4),
                Text(notification.timeAgo, style: TextStyle(fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500)),
              ]),
            ])),
          ],
        )),
      )),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title row — matches the filled-state header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Notifications',
            style: TextStyle(
              color: Theme.of(context).textTheme.displaySmall?.color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // Vertically centred empty-state content
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF20B2AA).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Color(0xFF20B2AA),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You're all caught up!\nMedication reminders will appear here.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
