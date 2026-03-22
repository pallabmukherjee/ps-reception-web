import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class ComplaintsService {
  // Function to fetch metadata (stations and sub-categories) from Laravel API
  Future<Map<String, dynamic>> fetchMetadata() async {
    try {
      final response = await ApiService.get('metadata');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load metadata');
      }
    } catch (e) {
      print('Error fetching metadata: $e');
      rethrow;
    }
  }

  // Function to fetch my complaints from Laravel API
  Future<List<Map<String, dynamic>>> fetchMyComplaints() async {
    try {
      final response = await ApiService.get('my-complaints');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load my complaints');
      }
    } catch (e) {
      print('Error fetching my complaints: $e');
      rethrow;
    }
  }

  // Function to store the complaint in Laravel API
  Future<Map<String, dynamic>> storeComplaint({
    required String name,
    required String phone,
    required String address,
    required int subCategoryId,
    String? description,
    required int policeStationId,
  }) async {
    try {
      final response = await ApiService.post('complaints', {
        'complainant_name': name,
        'phone': phone,
        'address': address,
        'sub_category_id': subCategoryId,
        'description': description ?? '',
        'police_station_id': policeStationId,
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Complaint stored successfully');
        return data;
      } else {
        throw Exception('Failed to store complaint: ${response.body}');
      }
    } catch (e) {
      print('Error storing complaint: $e');
      rethrow;
    }
  }
}
