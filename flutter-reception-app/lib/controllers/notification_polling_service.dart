import 'dart:async';
import 'dart:convert';
import 'package:kp_police/controllers/complaints_service.dart';
import 'package:kp_police/controllers/notification_service.dart';

class NotificationPollingService {
  static Timer? _timer;
  static final ComplaintsService _complaintsService = ComplaintsService();
  static bool _isPolling = false;

  static void startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    print("DEBUG: Starting notification polling...");
    _timer = Timer.periodic(Duration(seconds: 15), (timer) { // Reduced to 15 seconds for responsiveness
      _checkNotifications();
    });
    // Immediate first check
    _checkNotifications();
  }

  static void stopPolling() {
    _timer?.cancel();
    _isPolling = false;
    print("DEBUG: Stopped notification polling.");
  }

  static Future<void> _checkNotifications() async {
    try {
      print("DEBUG: Checking for new notifications...");
      final notifications = await _complaintsService.fetchNotifications();
      if (notifications.isNotEmpty) {
        print("DEBUG: Found ${notifications.length} new notifications");
        for (var notification in notifications) {
          dynamic data = notification['data'];
          
          // Handle both Map and String data (Laravel sometimes returns data as string if not cast)
          Map<String, dynamic> dataMap = {};
          if (data is String) {
            dataMap = Map<String, dynamic>.from(jsonDecode(data));
          } else if (data is Map) {
            dataMap = Map<String, dynamic>.from(data);
          }

          print("DEBUG: Showing notification: ${dataMap['title']}");
          
          await PushNotifications.showSimpleNotification(
            title: dataMap['title'] ?? 'New Alert',
            body: dataMap['message'] ?? 'A new high priority complaint has been registered.',
            payload: jsonEncode(dataMap),
          );
        }
        // Mark as read after showing local notifications
        await _complaintsService.markNotificationsRead();
      }
    } catch (e) {
      print("DEBUG: Error during notification polling: $e");
    }
  }
}
