import 'package:flutter/material.dart';
import 'package:wbpreception/controllers/api_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wbpreception/controllers/notification_service.dart';
import 'package:flutter/services.dart';
import 'layout/app_bar.dart';
import 'layout/custom_drawer.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('profile');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userData = data['user'];
          _fullNameController.text = _userData?['full_name'] ?? _userData?['name'] ?? '';
          _phoneController.text = _userData?['phone_number'] ?? '';
          _addressController.text = _userData?['address'] ?? '';
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching user data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUserData() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.post('profile', {
        'full_name': _fullNameController.text,
        'phone_number': _phoneController.text,
        'address': _addressController.text,
      });

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _fullNameController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          _fetchUserData();
        }
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  Future<void> _showDebugInfo() async {
    setState(() => _isLoading = true);
    String? token = await PushNotifications.getDeviceToken();
    
    try {
      final response = await ApiService.post('test-notification', {});
      setState(() => _isLoading = false);
      
      _showResultDialog(
        title: "Debug Information",
        content: "Device Token: $token\n\nServer Response:\n${response.body}",
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showResultDialog(
        title: "Debug Error",
        content: "Device Token: $token\n\nError: $e",
      );
    }
  }

  void _showResultDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: SelectableText(content)),
        actions: [
          if (content.contains("Device Token:"))
            TextButton(
              onPressed: () {
                final parts = content.split("Device Token: ");
                if (parts.length > 1) {
                  final token = parts[1].split("\n")[0].trim();
                  if (token != "null" && token.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: token));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Token copied to clipboard")));
                  }
                }
              }, 
              child: const Text("COPY TOKEN")
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CLOSE")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Official Profile", showBackButton: true),
      drawer: CustomDrawer(),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildForm(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _updateUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00137F),
                foregroundColor: Colors.white,
              ),
              child: const Text("UPDATE CREDENTIALS"),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _showDebugInfo,
              icon: const Icon(Icons.bug_report_outlined, color: Colors.orange),
              label: const Text("TEST NOTIFICATION & DEBUG", style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
            ],
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF00137F),
            child: Text(
              _fullNameController.text.isNotEmpty ? _fullNameController.text[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _fullNameController.text.isNotEmpty ? _fullNameController.text : 'Official Member',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        Text(
          _userData?['email'] ?? '',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFF0000).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "WEST BENGAL POLICE AUTHORITY",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFFF0000), letterSpacing: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Personal Details"),
        const SizedBox(height: 16),
        _buildTextField(_fullNameController, "Full Name", Icons.badge_outlined),
        const SizedBox(height: 20),
        _buildTextField(_phoneController, "Mobile Number", Icons.phone_android_rounded, isPhone: true),
        const SizedBox(height: 20),
        _buildTextField(_addressController, "Residential Address", Icons.home_work_outlined, maxLines: 2),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.blueGrey),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPhone = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00137F), size: 20),
      ),
    );
  }
}
