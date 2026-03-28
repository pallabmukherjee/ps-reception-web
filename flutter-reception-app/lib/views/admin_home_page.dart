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

  // Function to fetch the user's name from SharedPreferences
  Future<void> _fetchUserName() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userName = prefs.getString('user_name') ?? '';

      if (userName.isEmpty) {
        setState(() {
          _isProfileComplete = false;
        });
      } else {
        setState(() {
          _userName = userName;
          _isProfileComplete = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user data: $e')),
      );
    }
  }

  // Check if data exists in SharedPreferences
  Future<void> _checkDataExists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _dataExists = prefs.containsKey('receptionist_name') && prefs.containsKey('receptionist_mobile');
    });
  }

  // Function to add or remove data
  Future<void> _toggleData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_dataExists) {
      await prefs.remove('receptionist_name');
      await prefs.remove('receptionist_mobile');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Duty ended successfully!')),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/receptionist');
    }
    await _checkDataExists();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Home", showBackButton: false),
      drawer: CustomDrawer(),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFFFAF9F6),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'West Bengal ',
                      style: TextStyle(
                        color: Color(0xFFFF0000),
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Police',
                      style: TextStyle(
                        color: Color(0xFF00137F), // Blue color for "Police"
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Reception Management',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF57007F),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 40),
              Center(
                child: _isProfileComplete
                    ? Text(
                  'Welcome, $_userName',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                )
                    : Column(
                  children: [
                    Text(
                      'Your profile is not complete. Please complete your profile.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFdf0100),
                      ),
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // Useful Links Decorating the Dashboard
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildDashboardItem(
                    context,
                    title: "Add Complaint",
                    icon: Icons.add_circle_outline,
                    color: Colors.blue,
                    onTap: () => Navigator.pushNamed(context, '/add_complaint'),
                  ),
                  _buildDashboardItem(
                    context,
                    title: "View List",
                    icon: Icons.list_alt,
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, '/list_complaint'),
                  ),
                  _buildDashboardItem(
                    context,
                    title: "My Profile",
                    icon: Icons.person_outline,
                    color: Colors.green,
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                  _buildDashboardItem(
                    context,
                    title: _dataExists ? "End Duty" : "Join Duty",
                    icon: _dataExists ? Icons.work_off_outlined : Icons.work_outline,
                    color: _dataExists ? Colors.red : Colors.teal,
                    onTap: _toggleData,
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTabSelected: _onTabSelected,
        selectedIndex: _selectedIndex,
      ),
    );
  }

  Widget _buildDashboardItem(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
