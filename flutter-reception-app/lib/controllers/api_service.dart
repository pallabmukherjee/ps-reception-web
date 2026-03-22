import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://dist.jalpaiguripolice.com";

  static Future<Map<String, String>> getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    print('ApiService: Using token: ${token != null ? "FOUND" : "NOT FOUND"}');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/api/$endpoint");
    final headers = await getHeaders();
    return await http.post(url, headers: headers, body: jsonEncode(data));
  }

  static Future<http.Response> patch(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/api/$endpoint");
    final headers = await getHeaders();
    return await http.patch(url, headers: headers, body: jsonEncode(data));
  }

  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse("$baseUrl/api/$endpoint");
    final headers = await getHeaders();
    return await http.delete(url, headers: headers);
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse("$baseUrl/api/$endpoint");
    final headers = await getHeaders();
    return await http.get(url, headers: headers);
  }
}
