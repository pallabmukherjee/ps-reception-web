import 'dart:async';
import 'dart:convert';
import 'package:kp_police/controllers/complaints_service.dart';
import 'package:kp_police/controllers/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPollingService {
  static Timer? _timer;
  static final ComplaintsService _complaintsService = ComplaintsService();
  static bool _isPolling = false;

  static void startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    print("DEBUG: Starting notification polling...");
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) { 
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? dutyStartTimeStr = prefs.getString('duty_start_time');
      DateTime? dutyStartTime;
      if (dutyStartTimeStr != null) {
        dutyStartTime = DateTime.parse(dutyStartTimeStr);
      }

      print("DEBUG: Checking for new notifications...");
      final notifications = await _complaintsService.fetchNotifications();
      if (notifications.isNotEmpty) {
        print("DEBUG: Found ${notifications.length} new notifications");
        for (var notification in notifications) {
          dynamic data = notification['data'];
          
          Map<String, dynamic> dataMap = {};
          if (data is String) {
            dataMap = Map<String, dynamic>.from(jsonDecode(data));
          } else if (data is Map) {
            dataMap = Map<String, dynamic>.from(data);
          }

          // Filter by duty session if it's a note update or high priority for started duty
          if (dutyStartTime != null && dataMap['complaint_created_at'] != null) {
            DateTime complaintCreatedAt = DateTime.parse(dataMap['complaint_created_at']);
            if (complaintCreatedAt.isBefore(dutyStartTime)) {
              print("DEBUG: Skipping notification for old complaint (pre-duty)");
              continue;
            }
          }

          print("DEBUG: Showing notification: ${dataMap['title']}");
          
          await PushNotifications.showSimpleNotification(
            title: dataMap['title'] ?? 'New Alert',
            body: dataMap['message'] ?? 'A new notification has been received.',
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
