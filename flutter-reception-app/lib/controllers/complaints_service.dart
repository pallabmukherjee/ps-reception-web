import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class ComplaintsService {
  // Function to fetch categories from Laravel API
  Future<List<Map<String, dynamic>>> fetchSubCategories() async {
    try {
      final response = await ApiService.get('/metadata');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['sub_categories']);
      } else {
        throw Exception('Failed to load sub-categories');
      }
    } catch (e) {
      print('Error fetching sub-categories: $e');
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
      final response = await ApiService.post('/complaints', {
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
        
        // Optionally store locally as well
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> complaintIds = _getComplaintIds(prefs);
        complaintIds.add(data['id'].toString());
        await prefs.setString('complaint_ids', jsonEncode(complaintIds));

        return data;
      } else {
        throw Exception('Failed to store complaint: ${response.body}');
      }
    } catch (e) {
      print('Error storing complaint: $e');
      rethrow;
    }
  }

  // Helper method to retrieve existing complaint IDs from SharedPreferences
  List<String> _getComplaintIds(SharedPreferences prefs) {
    String? jsonString = prefs.getString('complaint_ids');
    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString);
      return List<String>.from(jsonList);
    }
    return [];
  }
}
