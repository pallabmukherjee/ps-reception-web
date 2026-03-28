import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../views/layout/app_bar.dart';
import '../views/layout/custom_drawer.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmNewPassword = _confirmNewPasswordController.text;

    if (newPassword.isEmpty || currentPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (newPassword != confirmNewPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Credentials updated successfully')));
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Modification failed: $e'), backgroundColor: Colors.red.shade600),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: "Security Settings", showBackButton: true),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            const SizedBox(height: 32),
            _buildPremiumField(_currentPasswordController, "Current Password", Icons.lock_outline_rounded),
            const SizedBox(height: 20),
            _buildPremiumField(_newPasswordController, "New Access Password", Icons.vpn_key_outlined),
            const SizedBox(height: 20),
            _buildPremiumField(_confirmNewPasswordController, "Confirm New Password", Icons.check_circle_outline_rounded),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("UPDATE ACCESS CREDENTIALS"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SECURITY MODIFICATION",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF00137F), letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        Text(
          "Ensure your account stays secure by periodically updating your access credentials.",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildPremiumField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00137F), size: 20),
      ),
    );
  }
}
