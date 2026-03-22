import 'package:flutter/material.dart';
import 'package:kp_police/controllers/complaints_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../layout/app_bar.dart';
import '../layout/custom_drawer.dart';

class EditComplaintScreen extends StatefulWidget {
  final Map<String, dynamic> complaint;

  EditComplaintScreen({required this.complaint});

  @override
  _EditComplaintScreenState createState() => _EditComplaintScreenState();
}

class _EditComplaintScreenState extends State<EditComplaintScreen> {
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
    _initFields();
    _loadMetadata();
  }

  void _initFields() {
    _nameController.text = widget.complaint['complainant_name'] ?? '';
    _phoneController.text = widget.complaint['phone'] ?? '';
    _addressController.text = widget.complaint['address'] ?? '';
    _descriptionController.text = widget.complaint['description'] ?? '';
    _selectedSubCategoryId = widget.complaint['sub_category_id'];
    _selectedStationId = widget.complaint['police_station_id'];
  }

  Future<void> _loadMetadata() async {
    try {
      final metadata = await _complaintsService.fetchMetadata();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _userRole = prefs.getString('user_role');

      setState(() {
        _subCategories = List<Map<String, dynamic>>.from(metadata['sub_categories']);
        _policeStations = List<Map<String, dynamic>>.from(metadata['police_stations']);
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
        await _complaintsService.updateComplaint(
          id: widget.complaint['id'],
          name: _nameController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          subCategoryId: _selectedSubCategoryId!,
          policeStationId: _selectedStationId!,
          description: _descriptionController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint updated successfully!')),
        );

        Navigator.pop(context, true);
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update complaint: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Update Complaint", showBackButton: true),
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
                ),
                validator: (value) => value!.isEmpty ? 'Please enter name' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  label: Text("Phone No"),
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
                ),
                validator: (value) => value!.isEmpty ? 'Please enter address' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  label: Text("Description (Optional)"),
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
                onChanged: null, // Always locked as per request
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
                  child: Text("Update Complaint", style: TextStyle(fontSize: 18, color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
