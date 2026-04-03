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
        throw Exception('Failed to load metadata: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching metadata: $e');
      rethrow;
    }
  }

  // Function to fetch my complaints from Laravel API
  Future<Map<String, dynamic>> fetchMyComplaints({
    String? search,
    String? startDate,
    String? endDate,
    String? dutyStartTime,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      String url = 'my-complaints?page=$page&per_page=$perPage';
      if (search != null && search.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(search)}';
      }
      if (startDate != null && startDate.isNotEmpty) {
        url += '&start_date=$startDate';
      }
      if (endDate != null && endDate.isNotEmpty) {
        url += '&end_date=$endDate';
      }
      if (dutyStartTime != null && dutyStartTime.isNotEmpty) {
        url += '&duty_start_time=$dutyStartTime';
      }

      final response = await ApiService.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load my complaints: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching my complaints: $e');
      rethrow;
    }
  }

  // Function to add a note to a complaint
  Future<Map<String, dynamic>> addNote(int complaintId, String note) async {
    try {
      final response = await ApiService.post('complaints/$complaintId/note', {
        'note': note,
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to add note: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding note: $e');
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
    required String receptionistName,
    required String receptionistMobile,
  }) async {
    try {
      final response = await ApiService.post('complaints', {
        'complainant_name': name,
        'phone': phone,
        'address': address,
        'sub_category_id': subCategoryId,
        'description': description ?? '',
        'police_station_id': policeStationId,
        'receptionist_name': receptionistName,
        'receptionist_mobile': receptionistMobile,
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

  // Function to update the complaint in Laravel API
  Future<Map<String, dynamic>> updateComplaint({
    required int id,
    required String name,
    required String phone,
    required String address,
    required int subCategoryId,
    String? description,
    required int policeStationId,
  }) async {
    try {
      final response = await ApiService.patch('complaints/$id', {
        'complainant_name': name,
        'phone': phone,
        'address': address,
        'sub_category_id': subCategoryId,
        'description': description ?? '',
        'police_station_id': policeStationId,
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update complaint: ${response.body}');
      }
    } catch (e) {
      print('Error updating complaint: $e');
      rethrow;
    }
  }

  // Function to delete the complaint in Laravel API
  Future<void> deleteComplaint(int id) async {
    try {
      final response = await ApiService.delete('complaints/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete complaint: ${response.body}');
      }
    } catch (e) {
      print('Error deleting complaint: $e');
      rethrow;
    }
  }

  // Function to fetch statistics from Laravel API
  Future<Map<String, dynamic>> fetchStatistics({int? policeStationId}) async {
    try {
      String url = 'statistics';
      if (policeStationId != null) {
        url += '?police_station_id=$policeStationId';
      }
      final response = await ApiService.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load statistics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching statistics: $e');
      rethrow;
    }
  }

  // Function to fetch a single complaint by ID
  Future<Map<String, dynamic>> fetchComplaint(int id, {String? dutyStartTime}) async {
    try {
      String url = 'complaints/$id';
      if (dutyStartTime != null && dutyStartTime.isNotEmpty) {
        url += '?duty_start_time=$dutyStartTime';
      }
      final response = await ApiService.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load complaint: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching complaint: $e');
      rethrow;
    }
  }
}
