import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wbpreception/controllers/notification_polling_service.dart';
import 'api_service.dart';

class AuthService {
  // User register function (Optional: can be added if needed in Laravel)
  static Future<String> createAccountWithEmail(String email, String password) async {
    return "Registration is handled by Admin";
  }

  // user login function
  static Future<String> loginWithEmail(String email, String password, {String? fcmToken}) async {
    try {
      final response = await ApiService.post('login', {
        'email': email,
        'password': password,
        'device_name': 'mobile_app',
        'fcm_token': fcmToken,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']?.toString() ?? '');
        await prefs.setString('user_role', data['user']['role']?.toString() ?? '');
        await prefs.setString('user_name', data['user']['name']?.toString() ?? '');
        
        if (data['user']['police_station_id'] != null) {
          await prefs.setString('user_ps_id', data['user']['police_station_id'].toString());
        }
        if (data['user']['police_station_notification_id'] != null) {
          await prefs.setString('user_ps_notification_id', data['user']['police_station_notification_id'].toString());
        }
        
        return "Login Successfully";
      } else {
        final errorData = jsonDecode(response.body);
        return errorData['message'] ?? "Login failed";
      }
    } catch (e) {
      return e.toString();
    }
  }

  // user logout function
  static Future logout() async {
    // Stop notification polling
    NotificationPollingService.stopPolling();
    
    try {
      await ApiService.post('logout', {});
    } catch (e) {
      print('Error calling logout API: $e');
    }
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_name');
    await prefs.remove('user_ps_id');
    await prefs.remove('user_ps_notification_id');
  }

  // update fcm token
  static Future<void> updateFcmToken(String? fcmToken) async {
    if (fcmToken == null) return;
    try {
      await ApiService.post('update-fcm-token', {'fcm_token': fcmToken});
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  // check user login in or not
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }
}
