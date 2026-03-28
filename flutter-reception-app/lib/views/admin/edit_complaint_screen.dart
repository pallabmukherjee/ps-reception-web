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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load metadata: $e')),
        );
      }
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
          const SnackBar(content: Text('Record modified successfully')),
        );

        Navigator.pop(context, true);
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Modify Complain", showBackButton: true),
      drawer: CustomDrawer(),
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
                    _buildEditSection("Subject Identity", Icons.edit_note_rounded),
                    const SizedBox(height: 16),
                    _buildPremiumField(_nameController, "Complainant Name", Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildPremiumField(_phoneController, "Contact Mobile", Icons.phone_android_rounded, isPhone: true),
                    const SizedBox(height: 16),
                    _buildPremiumField(_addressController, "Official Address", Icons.map_outlined, maxLines: 2),
                    
                    const SizedBox(height: 32),
                    _buildEditSection("Case Classification", Icons.shield_outlined),
                    const SizedBox(height: 16),
                    _buildPremiumDropdown(
                      "Alert Classification",
                      _subCategories,
                      _selectedSubCategoryId,
                      (val) => setState(() => _selectedSubCategoryId = val),
                      Icons.category_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildPremiumDropdown(
                      "Jurisdiction Station (Locked)",
                      _policeStations,
                      _selectedStationId,
                      null, // Station cannot be changed on edit as per design
                      Icons.account_balance_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildPremiumField(_descriptionController, "Full Statement", Icons.description_outlined, maxLines: 4),
                    
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text("UPDATE JURISDICTIONAL RECORD"),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildEditSection(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF00137F)),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Color(0xFF00137F)),
        ),
      ],
    );
  }

  Widget _buildPremiumField(TextEditingController controller, String label, IconData icon, {bool isPhone = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      validator: (value) => value!.isEmpty ? 'Entry required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueGrey.shade300, size: 20),
      ),
    );
  }

  Widget _buildPremiumDropdown(String label, List<Map<String, dynamic>> items, int? selectedValue, ValueChanged<int?>? onChanged, IconData icon) {
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
