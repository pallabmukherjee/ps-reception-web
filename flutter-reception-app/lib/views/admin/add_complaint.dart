import 'package:flutter/material.dart';
import 'package:kp_police/controllers/complaints_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../layout/app_bar.dart';
import '../layout/custom_bottom_nav.dart';

class AddComplaintScreen extends StatefulWidget {
  @override
  _AddComplaintScreenState createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final ComplaintsService _complaintsService = ComplaintsService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int? _selectedSubCategoryId;
  int? _selectedStationId;
  String? _userRole;

  List<Map<String, dynamic>> _subCategories = [];
  List<Map<String, dynamic>> _policeStations = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      final metadata = await _complaintsService.fetchMetadata();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userPsId = prefs.getString('user_ps_id');
      _userRole = prefs.getString('user_role');

      setState(() {
        _subCategories = List<Map<String, dynamic>>.from(metadata['sub_categories']);
        List<Map<String, dynamic>> allStations = List<Map<String, dynamic>>.from(metadata['police_stations']);
        _policeStations = allStations;
        
        if (userPsId != null && _userRole != 'admin' && _userRole != 'super') {
          int? psId = int.tryParse(userPsId);
          _selectedStationId = psId;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading metadata: $e')));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubCategoryId == null || _selectedStationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select type and station')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _complaintsService.storeComplaint(
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        subCategoryId: _selectedSubCategoryId!,
        policeStationId: _selectedStationId!,
        description: _descriptionController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complain registered successfully')));
      Navigator.pushReplacementNamed(context, '/list_complaint');
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed: $e')));
    }
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Register Complain", showBackButton: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: const Color(0xFFF8FAFC),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormSection("Complainant Information", Icons.person_outline),
                      const SizedBox(height: 16),
                      _buildTextField(_nameController, "Full Name", Icons.badge_outlined, "Enter complainant name"),
                      const SizedBox(height: 16),
                      _buildTextField(_phoneController, "Contact Number", Icons.phone_android_outlined, "Enter 10-digit mobile", isPhone: true),
                      const SizedBox(height: 16),
                      _buildTextField(_addressController, "Full Address", Icons.location_on_outlined, "Enter residential address", maxLines: 2),
                      
                      const SizedBox(height: 32),
                      _buildFormSection("Complain Details", Icons.gavel_outlined),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        "Complain Type",
                        _subCategories,
                        _selectedSubCategoryId,
                        (val) => setState(() => _selectedSubCategoryId = val),
                        Icons.category_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        "Jurisdiction Station",
                        _policeStations,
                        _selectedStationId,
                        (_userRole == 'admin' || _userRole == 'super') 
                          ? (val) => setState(() => _selectedStationId = val)
                          : null, // Disabled for receptionists/superiors
                        Icons.account_balance_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(_descriptionController, "Complain Description (Optional)", Icons.description_outlined, "Provide brief incident details", maxLines: 4),
                      
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("SUBMIT OFFICIAL RECORD"),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  Widget _buildFormSection(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF00137F)),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Color(0xFF00137F),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String hint, {bool isPhone = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      validator: (value) => value!.isEmpty ? 'This field is required' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blueGrey.shade300, size: 20),
      ),
    );
  }

  Widget _buildDropdown(String label, List<Map<String, dynamic>> items, int? selectedValue, ValueChanged<int?>? onChanged, IconData icon) {
    return DropdownButtonFormField<int>(
      value: selectedValue,
      onChanged: onChanged,
      validator: (value) => value == null ? 'Selection required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueGrey.shade300, size: 20),
      ),
      items: items.map((item) {
        return DropdownMenuItem<int>(
          value: int.tryParse(item['id'].toString()),
          child: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        );
      }).toList(),
    );
  }
}
