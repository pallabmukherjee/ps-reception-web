import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  // User register function (Optional: can be added if needed in Laravel)
  static Future<String> createAccountWithEmail(String email, String password) async {
    return "Registration is handled by Admin";
  }

  // user login function
  static Future<String> loginWithEmail(String email, String password) async {
    try {
      final response = await ApiService.post('/login', {
        'email': email,
        'password': password,
        'device_name': 'mobile_app', // You can dynamically get device name
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_role', data['user']['role']);
        await prefs.setString('user_name', data['user']['name']);
        
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
    try {
      await ApiService.post('/logout', {});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_role');
      await prefs.remove('user_name');
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  // check user login in or not
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }
}
