import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../layout/app_bar.dart';
import '../layout/custom_bottom_nav.dart';
import '../layout/custom_drawer.dart';

class ReceptionistFormScreen extends StatefulWidget {
  @override
  _ReceptionistFormScreenState createState() => _ReceptionistFormScreenState();
}

class _ReceptionistFormScreenState extends State<ReceptionistFormScreen> {
  int _selectedIndex = 1;
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _receptionistNameController = TextEditingController();
  final TextEditingController _receptionistMobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _receptionistNameController.text = prefs.getString('receptionist_name') ?? '';
      _receptionistMobileController.text = prefs.getString('receptionist_mobile') ?? '';
    });
  }

  Future<void> _saveData() async {
    if (_formKey.currentState?.validate() ?? false) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('receptionist_name', _receptionistNameController.text);
      await prefs.setString('receptionist_mobile', _receptionistMobileController.text);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Duty session started successfully')));
      Navigator.pushReplacementNamed(context, '/adminhome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Duty Registration", showBackButton: true),
      drawer: CustomDrawer(),
      body: Container(
        color: const Color(0xFFF8FAFC),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildPremiumField(_receptionistNameController, "Official Personnel Name", Icons.person_pin_rounded),
                const SizedBox(height: 20),
                _buildPremiumField(_receptionistMobileController, "Official Mobile Number", Icons.phone_android_rounded, isPhone: true),
                const SizedBox(height: 32),
                _buildPolicyNotice(),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _saveData,
                  child: const Text("START DUTY SESSION"),
                ),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "RECEPTION DESK AUTHENTICATION",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF00137F), letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        Text(
          "Register your current duty shift to begin managing official case records.",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildPremiumField(TextEditingController controller, String label, IconData icon, {bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      validator: (value) => value!.isEmpty ? 'This entry is mandatory' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00137F), size: 20),
      ),
    );
  }

  Widget _buildPolicyNotice() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF0000).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Color(0xFFFF0000), size: 18),
              SizedBox(width: 8),
              Text("OFFICIAL POLICY", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFFF0000), fontSize: 11, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Submitted complaints can be modified or removed only before ending current duty. No records can be edited after session termination.",
            style: TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.5, fontWeight: FontWeight.w500),
          ),
          const Divider(height: 24, color: Colors.black12),
          const Text(
            "সাবমিট করা কমপ্লেন ডিউটি এন্ড করার আগে পর্যন্ত এডিট বা ডিলিট করা যাবে। ডিউটি এন্ড করার পর আর কমপ্লেন এডিট বা ডিলিট করা যাবে না।",
            style: TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.5),
          ),
        ],
      ),
    );
  }
}
