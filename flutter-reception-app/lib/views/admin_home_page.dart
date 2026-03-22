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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
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
            ElevatedButton(
              onPressed: _toggleData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFa3d95d),
              ),
              child: Text(
                _dataExists ? "End Duty" : "Join Duty",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
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
}
