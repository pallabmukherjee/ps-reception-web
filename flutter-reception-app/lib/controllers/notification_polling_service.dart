import 'dart:async';
import 'package:kp_police/controllers/complaints_service.dart';
import 'package:kp_police/controllers/notification_service.dart';

class NotificationPollingService {
  static Timer? _timer;
  static final ComplaintsService _complaintsService = ComplaintsService();
  static bool _isPolling = false;

  static void startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    print("Starting notification polling...");
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _checkNotifications();
    });
    // Immediate first check
    _checkNotifications();
  }

  static void stopPolling() {
    _timer?.cancel();
    _isPolling = false;
    print("Stopped notification polling.");
  }

  static Future<void> _checkNotifications() async {
    try {
      final notifications = await _complaintsService.fetchNotifications();
      if (notifications.isNotEmpty) {
        print("Found ${notifications.length} new notifications");
        for (var notification in notifications) {
          final data = notification['data'];
          await PushNotifications.showSimpleNotification(
            title: data['title'] ?? 'New Alert',
            body: data['message'] ?? 'A new high priority complaint has been registered.',
            payload: data.toString(),
          );
        }
        // Mark as read after showing local notifications
        await _complaintsService.markNotificationsRead();
      }
    } catch (e) {
      print("Error during notification polling: $e");
    }
  }
}
