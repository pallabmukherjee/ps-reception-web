import 'dart:async';
import 'package:wbpreception/controllers/complaints_service.dart';

class NotificationPollingService {
  static Timer? _timer;
  static final ComplaintsService _complaintsService = ComplaintsService();
  static bool _isPolling = false;

  static void startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _checkNotifications();
    });
    // Immediate first check
    _checkNotifications();
  }

  static void stopPolling() {
    _timer?.cancel();
    _isPolling = false;
  }

  static Future<void> _checkNotifications() async {
    try {
      final notifications = await _complaintsService.fetchNotifications();

      if (notifications.isEmpty) return;

      // Mark as read — FCM handles push delivery, polling just clears the badge
      await _complaintsService.markNotificationsRead();

    } catch (e) {
      final errorStr = e.toString();
      if (!errorStr.contains("Failed host lookup") &&
          !errorStr.contains("SocketException")) {
        print('Notification polling error: $e');
      }
    }
  }
}
