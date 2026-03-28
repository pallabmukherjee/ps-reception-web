import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'layout/app_bar.dart';
import 'layout/custom_drawer.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  firebase_auth.User? _user;
  DocumentSnapshot? _userData;
  bool _isLoading = true;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = firebase_auth.FirebaseAuth.instance.currentUser;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (_user != null) {
      try {
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user_data')
            .where('email', isEqualTo: _user!.email)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          setState(() {
            _userData = userSnapshot.docs.first;
            _fullNameController.text = _userData!.get('full_name') ?? '';
            _phoneController.text = _userData!.get('phone_number') ?? '';
            _addressController.text = _userData!.get('address') ?? '';
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } catch (e) {
        print("Error fetching user data: $e");
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUserData() async {
    if (_user != null && _userData != null) {
      setState(() => _isLoading = true);
      try {
        await FirebaseFirestore.instance
            .collection('user_data')
            .doc(_userData!.id)
            .update({
          'full_name': _fullNameController.text,
          'phone_number': _phoneController.text,
          'address': _addressController.text,
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _fullNameController.text);

        String role = _userData!.get('role') ?? 'user';
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/adminhome');
        } else if (role == 'superior') {
          Navigator.pushReplacementNamed(context, '/superiorhome');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Official Profile", showBackButton: true),
      drawer: CustomDrawer(),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _user == null 
          ? _buildNoUser()
          : _buildProfileContent(),
    );
  }

  Widget _buildNoUser() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('No session active', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
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
          _user!.email ?? '',
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
