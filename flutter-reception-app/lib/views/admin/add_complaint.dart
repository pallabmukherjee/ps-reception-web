import 'package:flutter/material.dart';
import 'package:kp_police/controllers/complaints_service.dart';
import 'package:kp_police/controllers/push_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../layout/app_bar.dart';
import '../layout/custom_bottom_nav.dart';
import '../layout/custom_drawer.dart';

class AddComplaintScreen extends StatefulWidget {
  @override
  _AddComplaintScreenState createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen> {
  int _selectedIndex = 1;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int? _selectedSubCategoryId;
  int? _selectedStationId;
  List<Map<String, dynamic>> _subCategories = [];
  List<Map<String, dynamic>> _policeStations = [];
  bool _isLoading = true;
  String? _userRole;

  final ComplaintsService _complaintsService = ComplaintsService();

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadMetadata() async {
    try {
      final metadata = await _complaintsService.fetchMetadata();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userPsId = prefs.getString('user_ps_id');
      _userRole = prefs.getString('user_role');
      
      print('DEBUG: user_ps_id from prefs: $userPsId');
      print('DEBUG: user_role from prefs: $_userRole');

      setState(() {
        _subCategories = List<Map<String, dynamic>>.from(metadata['sub_categories']);
        List<Map<String, dynamic>> allStations = List<Map<String, dynamic>>.from(metadata['police_stations']);
        
        if (userPsId != null && _userRole != 'admin' && _userRole != 'super') {
          // Filter to only show the user's assigned station for non-admin/super
          int? psId = int.tryParse(userPsId);
          _policeStations = allStations.where((station) => (int.tryParse(station['id'].toString()) ?? -1) == psId).toList();
          
          if (_policeStations.isNotEmpty) {
            _selectedStationId = int.tryParse(_policeStations.first['id'].toString());
            print('DEBUG: Autoselected filtered station: $_selectedStationId');
          }
        } else {
          // Show all stations for admin/super
          _policeStations = allStations;
          
          if (userPsId != null) {
            int? psId = int.tryParse(userPsId);
            if (psId != null) {
              // Still try to autoselect the user's station from the full list
              bool exists = _policeStations.any((element) => (int.tryParse(element['id'].toString()) ?? -1) == psId);
              if (exists) {
                _selectedStationId = psId;
                print('DEBUG: Autoselected station for admin: $_selectedStationId');
              }
            }
          }
        }
        
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading metadata: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load metadata: $e')),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await _complaintsService.storeComplaint(
          name: _nameController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          subCategoryId: _selectedSubCategoryId!,
          policeStationId: _selectedStationId!,
          description: _descriptionController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint submitted successfully!')),
        );

        Navigator.pushReplacementNamed(context, '/thank-you');
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit complaint: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Add Complaint", showBackButton: false),
      drawer: CustomDrawer(),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  label: Text("Name of Complaint"),
                  hintText: "Enter Name of Complaint",
                ),
                validator: (value) => value!.isEmpty ? 'Please enter name' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  label: Text("Phone No"),
                  hintText: "Enter Phone No",
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter phone' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  label: Text("Address"),
                  hintText: "Enter Address",
                ),
                validator: (value) => value!.isEmpty ? 'Please enter address' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  label: Text("Description (Optional)"),
                  hintText: "Enter Description",
                ),
                maxLines: 4,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _selectedSubCategoryId,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  label: Text("Complain Type"),
                ),
                items: _subCategories.map((sub) {
                  return DropdownMenuItem<int>(
                    value: int.tryParse(sub['id'].toString()),
                    child: Text(sub['name']),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedSubCategoryId = val),
                validator: (val) => val == null ? 'Please select type' : null,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _selectedStationId,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  label: Text("Police Station"),
                ),
                items: _policeStations.map((station) {
                  return DropdownMenuItem<int>(
                    value: int.tryParse(station['id'].toString()),
                    child: Text(station['name']),
                  );
                }).toList(),
                onChanged: null, // Always locked for all users as per request
                validator: (val) => val == null ? 'Please select station' : null,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFa3d95d),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text("Submit Complaint", style: TextStyle(fontSize: 18, color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
