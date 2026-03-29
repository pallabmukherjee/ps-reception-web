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
      await prefs.remove('duty_start_time');
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
      },
      child: Scaffold(
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
                      "OFFICIAL SERVICES",
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
                        _buildBeautifiedCard(
                          context,
                          title: "Add Complain",
                          subtitle: "Register report",
                          icon: Icons.add_moderator_rounded,
                          color: const Color(0xFF00137F),
                          bgColor: const Color(0xFFE8EAF6),
                          onTap: () => Navigator.pushNamed(context, '/add_complaint'),
                        ),
                        _buildBeautifiedCard(
                          context,
                          title: "Complain Records",
                          subtitle: "Review history",
                          icon: Icons.assignment_rounded,
                          color: const Color(0xFFFF0000),
                          bgColor: const Color(0xFFFFEBEE),
                          onTap: () => Navigator.pushNamed(context, '/list_complaint'),
                        ),
                        _buildBeautifiedCard(
                          context,
                          title: "Profile",
                          subtitle: "Officer info",
                          icon: Icons.account_circle_rounded,
                          color: Colors.green.shade700,
                          bgColor: const Color(0xFFE8F5E9),
                          onTap: () => Navigator.pushNamed(context, '/profile'),
                        ),
                        _buildBeautifiedCard(
                          context,
                          title: _dataExists ? "End Duty" : "Join Duty",
                          subtitle: _dataExists ? "Shift end" : "Shift start",
                          icon: _dataExists ? Icons.logout_rounded : Icons.login_rounded,
                          color: _dataExists ? Colors.orange.shade800 : Colors.teal.shade700,
                          bgColor: _dataExists ? const Color(0xFFFFF3E0) : const Color(0xFFE0F2F1),
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
                  style: TextStyle(color: Color(0xFFFF0000), fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
                ),
                TextSpan(
                  text: 'Police',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'RECEPTION MANAGEMENT SYSTEM',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
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
                        _isProfileComplete ? 'Official Receptionist Personnel' : 'Please update your details',
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

  Widget _buildBeautifiedCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white,
              blurRadius: 0,
              offset: const Offset(0, 0),
            ),
          ],
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -15,
                bottom: -15,
                child: Icon(icon, size: 100, color: color.withOpacity(0.06)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
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
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: color.withOpacity(0.6),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
