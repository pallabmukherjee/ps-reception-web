import 'dart:async';
import 'dart:convert';
import 'package:wbpreception/controllers/complaints_service.dart';
import 'package:wbpreception/controllers/notification_service.dart';
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
      String? userRole = prefs.getString('user_role');
      
      print("🔔 POLLING DEBUG: Checking API for notifications... Role: $userRole");
      
      final notifications = await _complaintsService.fetchNotifications();
      
      if (notifications.isEmpty) {
        print("🔔 POLLING DEBUG: No unread notifications returned from API.");
        return;
      }

      print("🔔 POLLING DEBUG: Received ${notifications.length} raw notifications from API.");

      for (var notification in notifications) {
        print("🔔 POLLING DEBUG: Processing notification ID: ${notification['id']}");
        dynamic data = notification['data'];
        Map<String, dynamic> dataMap = {};
        
        if (data is String) {
          dataMap = Map<String, dynamic>.from(jsonDecode(data));
        } else if (data is Map) {
          dataMap = Map<String, dynamic>.from(data);
        }

        print("🔔 POLLING DEBUG: Notification Content: Title='${dataMap['title']}', Type='${dataMap['type']}'");

        // Duty Session Filter Check
        if (dutyStartTimeStr != null && dataMap['complaint_created_at'] != null) {
          DateTime dutyStartTime = DateTime.parse(dutyStartTimeStr);
          DateTime complaintTime = DateTime.parse(dataMap['complaint_created_at']);
          
          if (complaintTime.isBefore(dutyStartTime)) {
            print("🔔 POLLING DEBUG: FILTERED OUT - Complaint time ($complaintTime) is before duty start ($dutyStartTime)");
            continue;
          }
        }

        print("🔔 POLLING DEBUG: TRIGGERING LOCAL DISPLAY for '${dataMap['title']}'");
        await PushNotifications.showSimpleNotification(
          title: dataMap['title'] ?? 'New Alert',
          body: dataMap['message'] ?? 'New notification received.',
          payload: jsonEncode(dataMap),
        );
      }
      
      // Mark as read ONLY after processing
      await _complaintsService.markNotificationsRead();
      print("🔔 POLLING DEBUG: All notifications processed and marked as read on server.");
      
    } catch (e) {
      print("🔔 POLLING DEBUG: ERROR during poll: $e");
    }
  }
}
