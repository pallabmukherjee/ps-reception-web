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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? dutyStartTimeStr = prefs.getString('duty_start_time');

      final notifications = await _complaintsService.fetchNotifications();

      if (notifications.isEmpty) return;

      for (var notification in notifications) {
        dynamic data = notification['data'];
        Map<String, dynamic> dataMap = {};

        if (data is String) {
          dataMap = Map<String, dynamic>.from(jsonDecode(data));
        } else if (data is Map) {
          dataMap = Map<String, dynamic>.from(data);
        }

        // Dedup: skip if FCM already showed this notification
        final String? complaintId = dataMap['complaint_id']?.toString();
        if (complaintId != null && PushNotifications.shownComplaintIds.contains(complaintId)) {
          continue;
        }

        // Duty Session Filter Check
        if (dutyStartTimeStr != null && dataMap['complaint_created_at'] != null) {
          DateTime dutyStartTime = DateTime.parse(dutyStartTimeStr).toLocal();
          DateTime complaintTime = DateTime.parse(dataMap['complaint_created_at']).toLocal();

          if (complaintTime.isBefore(dutyStartTime)) continue;
        }

        // Track so neither path re-shows this notification
        if (complaintId != null) {
          PushNotifications.shownComplaintIds.add(complaintId);
        }

        await PushNotifications.showSimpleNotification(
          title: dataMap['title'] ?? '🚨 Emergency Alert',
          body: dataMap['message'] ?? 'New notification received.',
          payload: jsonEncode(dataMap),
        );
      }

      // Mark as read after processing
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
