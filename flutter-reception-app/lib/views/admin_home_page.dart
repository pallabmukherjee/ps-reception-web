import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'layout/app_bar.dart';
import 'layout/custom_drawer.dart';
import 'layout/custom_bottom_nav.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;
  String _userName = '';
  bool _isProfileComplete = true;
  bool _dataExists = false;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _checkDataExists();
  }

  Future<void> _fetchUserName() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userName = prefs.getString('user_name') ?? '';
      setState(() {
        _userName = userName;
        _isProfileComplete = userName.isNotEmpty;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _checkDataExists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _dataExists = prefs.containsKey('receptionist_name') && prefs.containsKey('receptionist_mobile');
    });
  }

  Future<void> _toggleData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_dataExists) {
      await prefs.remove('receptionist_name');
      await prefs.remove('receptionist_mobile');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duty ended successfully!')),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/receptionist');
    }
    await _checkDataExists();
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Dashboard", showBackButton: false),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "QUICK ACCESS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildPremiumCard(
                        context,
                        title: "Add Complaint",
                        subtitle: "Register new case",
                        icon: Icons.add_moderator_outlined,
                        color: const Color(0xFF00137F),
                        onTap: () => Navigator.pushNamed(context, '/add_complaint'),
                      ),
                      _buildPremiumCard(
                        context,
                        title: "Case Records",
                        subtitle: "View all history",
                        icon: Icons.assignment_outlined,
                        color: const Color(0xFFFF0000),
                        onTap: () => Navigator.pushNamed(context, '/list_complaint'),
                      ),
                      _buildPremiumCard(
                        context,
                        title: "My Profile",
                        subtitle: "Account settings",
                        icon: Icons.account_circle_outlined,
                        color: Colors.green,
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                      ),
                      _buildPremiumCard(
                        context,
                        title: _dataExists ? "End Duty" : "Join Duty",
                        subtitle: _dataExists ? "Finish session" : "Start session",
                        icon: _dataExists ? Icons.logout_rounded : Icons.login_rounded,
                        color: _dataExists ? Colors.orange : Colors.teal,
                        onTap: _toggleData,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTabSelected: _onTabSelected,
        selectedIndex: _selectedIndex,
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF00137F),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'West Bengal ',
                  style: TextStyle(
                    color: Color(0xFFFF0000),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextSpan(
                  text: 'Police',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'RECEPTION MANAGEMENT SYSTEM',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Color(0xFF00137F), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isProfileComplete ? 'Welcome, $_userName' : 'Profile Incomplete',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _isProfileComplete ? 'Logged in as Receptionist' : 'Please update your details',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
